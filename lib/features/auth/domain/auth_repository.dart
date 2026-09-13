part of auth;

/// Thrown when the user cancels the sign-in flow.
class SignInCancelledException implements Exception {
  const SignInCancelledException();
}

/// Thrown when Firebase returns a null user after a credential sign-in.
class SignInFailedException implements Exception {
  const SignInFailedException();
}

/// Contract for all authentication operations.
abstract class AuthRepository {
  /// Emits the current user on every auth-state change.
  /// Emits `null` when signed out.
  Stream<AuthUser?> get authStateChanges;

  /// The currently signed-in user, or `null` in guest mode.
  AuthUser? get currentUser;

  // ── Social sign-in ────────────────────────────────────────────────────────

  /// Signs in via Google OAuth.
  ///
  /// Throws [SignInCancelledException] when the user dismisses the dialog.
  Future<AuthUser> signInWithGoogle();

  /// Signs in via Apple ID (iOS / macOS only).
  Future<AuthUser> signInWithApple();

  // ── Email / password ──────────────────────────────────────────────────────

  /// Signs in an existing user with [email] and [password].
  Future<AuthUser> signInWithEmailAndPassword(String email, String password);

  /// Creates a new account and returns the signed-in user.
  Future<AuthUser> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  );

  /// Sends a password-reset e-mail to [email].
  Future<void> sendPasswordResetEmail(String email);

  // ── Sign-out ──────────────────────────────────────────────────────────────

  /// Signs out from Firebase (and Google, if that was the sign-in method).
  Future<void> signOut();
}
