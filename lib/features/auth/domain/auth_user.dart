part of auth;

/// Authenticated user returned by [AuthRepository].
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  static const String _appleRelayDomain = '@privaterelay.appleid.com';

  /// The email worth showing in the UI, or null when there is none.
  ///
  /// Apple's "Hide My Email" addresses are random strings that tell the user
  /// nothing, so they count as no email.
  String? get visibleEmail {
    final String? value = email?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.toLowerCase().endsWith(_appleRelayDomain)) return null;
    return value;
  }

  @override
  List<Object?> get props => <Object?>[uid, email, displayName, photoUrl];
}
