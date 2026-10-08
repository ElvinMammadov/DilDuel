part of auth;

/// Outcome of [AuthCubit.deleteAccount].
enum DeleteAccountResult {
  success,
  cancelled,
  wrongPassword,
  networkError,
  failed,
}

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository,
    this._bookmarkRepository,
    this._quizResultRepository,
    this._trainingProgressRepository,
    this._listeningResultRepository,
  ) : super(const AuthInitial());

  final AuthRepository _authRepository;
  final BookmarkRepository _bookmarkRepository;
  final QuizResultRepository _quizResultRepository;
  final TrainingProgressRepository _trainingProgressRepository;
  final ListeningResultRepository _listeningResultRepository;
  StreamSubscription<AuthUser?>? _authSub;
  bool _isDeletingAccount = false;

  /// Subscribes to Firebase auth-state changes. Call once at app start.
  void init() {
    _authSub = _authRepository.authStateChanges.listen(
      (AuthUser? user) async {
        if (user != null) {
          // If the user accumulated guest data, let them decide whether to
          // keep it (sync) or discard it before completing sign-in.
          if (await DBHelper.hasUserData()) {
            emit(AuthGuestDataDecision(user));
          } else {
            await _syncOnSignIn(user.uid);
            emit(AuthAuthenticated(user));
          }
        } else {
          // Clear user-specific local data before emitting so that listeners
          // reacting to AuthUnauthenticated (e.g. cached Cubits resetting)
          // always observe an already-empty database. This also handles the
          // account-switch case where Firebase signs out user A and signs in
          // user B without an explicit signOut() call.
          await DBHelper.clearUserData();
          emit(_isDeletingAccount
              ? const AuthAccountDeleted()
              : const AuthUnauthenticated());
        }
      },
      onError: (Object e) {
        log('Auth stream error: $e', name: 'AuthCubit');
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// Merges remote data into local storage for the three synced data
  /// types. The repositories are registered as their abstract interfaces,
  /// so the sync-specific merge method is reached via the concrete type.
  Future<void> _syncOnSignIn(String uid) async {
    try {
      await Future.wait(<Future<void>>[
        (_bookmarkRepository as SyncBookmarkRepository).mergeOnSignIn(uid),
        (_quizResultRepository as SyncQuizResultRepository).mergeOnSignIn(uid),
        (_trainingProgressRepository as SyncTrainingProgressRepository)
            .mergeOnSignIn(uid),
        (_listeningResultRepository as SyncListeningResultRepository)
            .mergeOnSignIn(uid),
      ]);
    } catch (e) {
      log('Sign-in sync error: $e', name: 'AuthCubit');
    }
  }

  bool get isSignedIn => state is AuthAuthenticated;

  AuthUser? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  // ── Social sign-in ────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      // Auth stream emits AuthAuthenticated automatically.
    } on SignInCancelledException {
      emit(const AuthUnauthenticated());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      log('Google sign-in error: $e', name: 'AuthCubit');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithApple() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithApple();
    } on SignInCancelledException {
      emit(const AuthUnauthenticated());
    } on SignInWithAppleAuthorizationException catch (e) {
      // User dismissed the sheet — not an error worth surfacing.
      if (e.code == AuthorizationErrorCode.canceled) {
        emit(const AuthUnauthenticated());
      } else {
        log('Apple sign-in error: $e', name: 'AuthCubit');
        emit(AuthError(e.message));
      }
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      log('Apple sign-in error: $e', name: 'AuthCubit');
      emit(AuthError(e.toString()));
    }
  }

  // ── Email / password ──────────────────────────────────────────────────────

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      log('Email sign-in error: $e', name: 'AuthCubit');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.registerWithEmailAndPassword(
          email, password, displayName);
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      log('Register error: $e', name: 'AuthCubit');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(const AuthPasswordResetSent());
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      log('Password reset error: $e', name: 'AuthCubit');
      emit(AuthError(e.toString()));
    }
  }

  // ── Guest data decision ───────────────────────────────────────────────────

  /// Merges all local guest data into the signed-in account, then completes
  /// sign-in. Called when the user chooses to keep their guest data.
  Future<void> keepGuestData() async {
    final AuthState s = state;
    if (s is! AuthGuestDataDecision) return;
    emit(const AuthLoading());
    await _syncOnSignIn(s.user.uid);
    emit(AuthAuthenticated(s.user));
  }

  /// Discards local guest data, pulls only the account's remote data, then
  /// completes sign-in. Called when the user chooses not to keep guest data.
  Future<void> discardGuestData() async {
    final AuthState s = state;
    if (s is! AuthGuestDataDecision) return;
    emit(const AuthLoading());
    await DBHelper.clearUserData();
    await _syncOnSignIn(s.user.uid);
    emit(AuthAuthenticated(s.user));
  }

  // ── Sign-out ──────────────────────────────────────────────────────────────

  /// Resets an [AuthError] state back to [AuthUnauthenticated] so the same
  /// error message can be shown again on the next failed attempt.
  void clearError() {
    if (state is AuthError) emit(const AuthUnauthenticated());
  }

  Future<void> signOut() async {
    try {
      // Send queued training progress while the user is still authenticated.
      await _trainingProgressRepository.flush();
      await _authRepository.signOut();
      // DB clearing and AuthUnauthenticated emission are handled by the
      // auth stream listener when authStateChanges emits null after sign-out.
    } catch (e) {
      log('Sign-out error: $e', name: 'AuthCubit');
      // If sign-out throws, clear locally and emit so the app stays consistent.
      await DBHelper.clearUserData();
      emit(const AuthUnauthenticated());
    }
  }

  // ── Account deletion ──────────────────────────────────────────────────────

  /// Whether deleting the account requires the user's password.
  bool get deletionNeedsPassword => _authRepository.hasPasswordSignIn;

  /// Permanently deletes the signed-in user's account and cloud data.
  ///
  /// On success the auth stream emits [AuthAccountDeleted] after local data
  /// has been cleared. State is left untouched on failure so the user stays
  /// signed in.
  Future<DeleteAccountResult> deleteAccount({String? password}) async {
    _isDeletingAccount = true;
    try {
      // Send queued progress first so nothing is written after deletion.
      await _trainingProgressRepository.flush();
      await _authRepository.deleteAccount(password: password);
      return DeleteAccountResult.success;
    } catch (e) {
      log('Delete account error: $e', name: 'AuthCubit');
      return _deleteResultFor(e);
    } finally {
      _isDeletingAccount = false;
    }
  }

  DeleteAccountResult _deleteResultFor(Object error) => switch (error) {
        SignInCancelledException() => DeleteAccountResult.cancelled,
        SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
        ) =>
          DeleteAccountResult.cancelled,
        fb.FirebaseAuthException(
          code: 'wrong-password' || 'invalid-credential',
        ) =>
          DeleteAccountResult.wrongPassword,
        fb.FirebaseAuthException(code: 'network-request-failed') =>
          DeleteAccountResult.networkError,
        _ => DeleteAccountResult.failed,
      };

  // ── Firebase error mapping ────────────────────────────────────────────────

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-poçt ünvanı ilə hesab tapılmadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-poçt və ya şifrə yanlışdır.';
      case 'email-already-in-use':
        return 'Bu e-poçt ünvanı artıq istifadə olunur.';
      case 'weak-password':
        return 'Şifrə çox zəifdir. Ən az 6 simvol daxil edin.';
      case 'invalid-email':
        return 'E-poçt ünvanı düzgün formatda deyil.';
      case 'user-disabled':
        return 'Bu hesab deaktiv edilib.';
      case 'too-many-requests':
        return 'Çox sayda cəhd. Bir az gözləyib yenidən cəhd edin.';
      case 'network-request-failed':
        return 'Şəbəkə xətası. İnternet bağlantınızı yoxlayın.';
      case 'operation-not-allowed':
        return 'Bu giriş üsulu aktiv deyil.';
      default:
        return e.message ?? 'Bilinməyən xəta baş verdi.';
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
