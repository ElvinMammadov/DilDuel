import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/quiz_result_repository.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';

/// Quiz-result repository backed by local SQLite via [DBHelper].
@lazySingleton
class LocalQuizResultRepository implements QuizResultRepository {
  @override
  Future<void> insertQuizResult(QuizResult result) async =>
      DBHelper.insertQuizResult(result);

  @override
  Future<List<QuizResult>> getQuizResults() => DBHelper.getQuizResults();

  @override
  Future<Map<String, dynamic>> getQuizStatistics() =>
      DBHelper.getQuizStatistics();
}