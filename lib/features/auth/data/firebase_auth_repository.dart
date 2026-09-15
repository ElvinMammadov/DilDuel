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

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

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
        fb.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

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

  // ── Helpers ───────────────────────────────────────────────────────────────

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
