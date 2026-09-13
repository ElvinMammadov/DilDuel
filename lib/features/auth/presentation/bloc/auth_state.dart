part of auth;

sealed class AuthState extends Equatable {
  const AuthState();
}

/// Initial state before the auth stream is subscribed.
class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => <Object?>[];
}

/// Any auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => <Object?>[];
}

/// The user is signed in.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
  @override
  List<Object?> get props => <Object?>[user];
}

/// No user is signed in — guest / local-only mode.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object?> get props => <Object?>[];
}

/// Password-reset e-mail was sent successfully.
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
  @override
  List<Object?> get props => <Object?>[];
}

/// An auth operation failed with a user-facing [message].
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override
  List<Object?> get props => <Object?>[message];
}
