/// Firestore collection names shared by the remote repositories and by
/// account deletion, so a new per-user collection is registered in one place.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String bookmarks = 'bookmarks';
  static const String unknownWords = 'unknownWords';
  static const String quizResults = 'quizResults';
  static const String listeningResults = 'listeningResults';
  static const String trainingProgress = 'trainingProgress';

  /// Top-level collection of user feedback; not tied to a user, so account
  /// deletion leaves it alone.
  static const String feedback = 'feedback';

  /// Every collection stored under `users/{uid}`. Account deletion removes
  /// all of them, so add new per-user collections here.
  static const List<String> userSubcollections = <String>[
    bookmarks,
    unknownWords,
    quizResults,
    listeningResults,
    trainingProgress,
  ];

  /// Path of the [name] collection belonging to [uid].
  static String userCollection(String uid, String name) => '$users/$uid/$name';
}
