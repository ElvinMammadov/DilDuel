import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/listening_result_repository.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocalListeningResultRepository implements ListeningResultRepository {
  @override
  Future<void> insertListeningResult(QuizResult result) =>
      DBHelper.insertListeningResult(result);

  @override
  Future<List<QuizResult>> getListeningResults() =>
      DBHelper.getListeningResults();

  @override
  Future<Map<String, dynamic>> getListeningStatistics() =>
      DBHelper.getListeningStatistics();
}
