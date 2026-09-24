import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';

abstract class ListeningResultRepository {
  Future<void> insertListeningResult(QuizResult result);
  Future<List<QuizResult>> getListeningResults();
  Future<Map<String, dynamic>> getListeningStatistics();
}
