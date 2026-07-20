/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App information
  static const String appName = 'Dictionary';
  static const String appVersion = '1.0.0';

  // Database constants
  static const String dbName = 'luget.db';
  static const int dbVersion = 1;

  // Dictionary types
  static const String deAz = 'DeAz';
  static const String azDe = 'AzDe';

  // Table names
  static const String bookmarkTable = 'bookmark';
  static const String quizResultsTable = 'quiz_results';

  // Column names
  static const String colKey = 'key';
  static const String colValue = 'value';
  static const String colType = 'type';
  static const String colDateTime = 'dateTime';
  static const String colScore = 'score';
  static const String colTotalQuestions = 'totalQuestions';

  // Quiz constants
  static const int minQuizWords = 4;
  static const int maxQuizWords = 10;
  static const int wrongAnswersPerQuestion = 3;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
