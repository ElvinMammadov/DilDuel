import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';

/// Contract for persisting and retrieving quiz results.
abstract class QuizResultRepository {
  /// Saves [result] to the backing store.
  Future<void> insertQuizResult(QuizResult result);

  /// Returns all saved results, newest first.
  Future<List<QuizResult>> getQuizResults();

  /// Returns aggregate statistics (totalQuizzes, averageScore).
  Future<Map<String, dynamic>> getQuizStatistics();
}