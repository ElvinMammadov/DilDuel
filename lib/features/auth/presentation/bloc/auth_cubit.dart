part of auth;

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthInitial());

  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _authSub;

  /// Subscribes to Firebase auth-state changes. Call once at app start.
  void init() {
    _authSub = _authRepository.authStateChanges.listen(
      (AuthUser? user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
      onError: (Object e) {
        log('Auth stream error: $e', name: 'AuthCubit');
        emit(const AuthUnauthenticated());
      },
    );
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

  // ── Sign-out ──────────────────────────────────────────────────────────────

  /// Resets an [AuthError] state back to [AuthUnauthenticated] so the same
  /// error message can be shown again on the next failed attempt.
  void clearError() {
    if (state is AuthError) emit(const AuthUnauthenticated());
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      log('Sign-out error: $e', name: 'AuthCubit');
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

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
