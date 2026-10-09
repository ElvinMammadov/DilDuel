/// A report from the user about a wrong word or translation, or an idea.
///
/// The length limits are enforced by `firestore.rules` as well; keep both in
/// sync.
class FeedbackSubmission {
  const FeedbackSubmission({required this.name, required this.message});

  static const int nameMaxLength = 60;
  static const int messageMaxLength = 1000;

  final String name;
  final String message;
}
