part of auth;

@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository()
      : _auth = fb.FirebaseAuth.instance,
        // serverClientId (web OAuth 2.0 client ID) is required by
        // google_sign_in_android 6.x (Credential Manager API).
        _googleSignIn = GoogleSignIn(
          serverClientId: '503985897884-57qsl94s8pg6jbacl5175gcth5s0kbs8'
              '.apps.googleusercontent.com',
        );

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  // ── Google ────────────────────────────────────────────────────────────────

  @override
  Future<AuthUser> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw const SignInCancelledException();

    final fb.OAuthCredential credential = await _googleCredential(googleUser);

    final fb.UserCredential result =
        await _auth.signInWithCredential(credential);
    final fb.User? user = result.user;
    if (user == null) throw const SignInFailedException();
    await _upsertUserEmail(user);
    return _toAuthUser(user)!;
  }

  // ── Apple ─────────────────────────────────────────────────────────────────

  @override
  Future<AuthUser> signInWithApple() async {
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final fb.OAuthCredential credential =
        _appleOAuthCredential(appleCredential);

    final fb.UserCredential result =
        await _auth.signInWithCredential(credential);
    final fb.User? user = result.user;
    if (user == null) throw const SignInFailedException();

    // Apple only returns name on first sign-in — update profile if present.
    final String? givenName = appleCredential.givenName;
    final String? familyName = appleCredential.familyName;
    if (givenName != null || familyName != null) {
      await user.updateDisplayName(
        '${givenName ?? ''} ${familyName ?? ''}'.trim(),
      );
      await user.reload();
    }

    await _upsertUserEmail(user);
    return _toAuthUser(_auth.currentUser)!;
  }

  // ── Email / password ──────────────────────────────────────────────────────

  @override
  Future<AuthUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final fb.UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final fb.User? user = result.user;
    if (user == null) throw const SignInFailedException();
    await _upsertUserEmail(user);
    return _toAuthUser(user)!;
  }

  @override
  Future<AuthUser> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final fb.UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final fb.User? user = result.user;
    if (user == null) throw const SignInFailedException();

    await user.updateDisplayName(displayName.trim());
    await user.reload();
    await _upsertUserEmail(user);
    return _toAuthUser(_auth.currentUser)!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ── Sign-out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    await Future.wait(<Future<void>>[
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Account deletion ──────────────────────────────────────────────────────

  static const int _batchLimit = 400;

  @override
  bool get hasPasswordSignIn => _providerIds.contains('password');

  Set<String> get _providerIds => <String>{
        for (final fb.UserInfo info
            in _auth.currentUser?.providerData ?? <fb.UserInfo>[])
          info.providerId,
      };

  @override
  Future<void> deleteAccount({String? password}) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return;

    // Re-authenticate first so a failed prompt leaves all data untouched.
    final String? appleAuthorizationCode =
        await _reauthenticate(user, password);
    await _deleteUserData(user.uid);
    if (appleAuthorizationCode != null) {
      await _revokeAppleToken(appleAuthorizationCode);
    }
    await user.delete();
    await _googleSignIn.signOut();
  }

  /// Re-authenticates with the provider the account uses. Returns the Apple
  /// authorization code when the account uses Sign in with Apple, so the
  /// token can be revoked after deletion.
  Future<String?> _reauthenticate(fb.User user, String? password) async {
    final Set<String> providers = _providerIds;
    if (providers.contains('password')) {
      await _reauthenticateWithPassword(user, password);
    } else if (providers.contains('google.com')) {
      await _reauthenticateWithGoogle(user);
    } else if (providers.contains('apple.com')) {
      return _reauthenticateWithApple(user);
    }
    return null;
  }

  Future<void> _reauthenticateWithPassword(
    fb.User user,
    String? password,
  ) async {
    final String? email = user.email;
    if (email == null || password == null) {
      throw fb.FirebaseAuthException(code: 'wrong-password');
    }
    await user.reauthenticateWithCredential(
      fb.EmailAuthProvider.credential(email: email, password: password),
    );
  }

  Future<void> _reauthenticateWithGoogle(fb.User user) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw const SignInCancelledException();
    await user.reauthenticateWithCredential(
      await _googleCredential(googleUser),
    );
  }

  Future<String> _reauthenticateWithApple(fb.User user) async {
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: <AppleIDAuthorizationScopes>[],
    );
    await user.reauthenticateWithCredential(
      _appleOAuthCredential(appleCredential),
    );
    return appleCredential.authorizationCode;
  }

  Future<void> _deleteUserData(String uid) async {
    final DocumentReference<Map<String, dynamic>> userDoc =
        FirebaseFirestore.instance.collection(FirestorePaths.users).doc(uid);
    for (final String name in FirestorePaths.userSubcollections) {
      await _deleteCollection(userDoc.collection(name));
    }
    await userDoc.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        (await collection.get()).docs;
    for (int i = 0; i < docs.length; i += _batchLimit) {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      docs.skip(i).take(_batchLimit).forEach(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                batch.delete(doc.reference),
          );
      await batch.commit();
    }
  }

  /// Apple requires revoking the Sign in with Apple token when an account is
  /// deleted. Failure must not block deletion, so it is only logged.
  Future<void> _revokeAppleToken(String authorizationCode) async {
    try {
      await _auth.revokeTokenWithAuthorizationCode(authorizationCode);
    } catch (e) {
      log('Apple token revocation failed: $e', name: 'FirebaseAuthRepository');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<fb.OAuthCredential> _googleCredential(
    GoogleSignInAccount googleUser,
  ) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    return fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  fb.OAuthCredential _appleOAuthCredential(
    AuthorizationCredentialAppleID appleCredential,
  ) =>
      fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

  /// Writes the user's email to `users/{uid}` so the account is identifiable
  /// when browsing the Firestore console.
  Future<void> _upsertUserEmail(fb.User user) async {
    if (user.email == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(<String, Object?>{'email': user.email}, SetOptions(merge: true));
  }

  AuthUser? _toAuthUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
