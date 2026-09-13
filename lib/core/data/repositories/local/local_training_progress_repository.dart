import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:injectable/injectable.dart';

/// Training-progress repository backed by local SQLite via [DBHelper].
@lazySingleton
class LocalTrainingProgressRepository implements TrainingProgressRepository {
  @override
  Future<int> getLevelPosition(String level) =>
      DBHelper.getLevelPosition(level);

  @override
  Future<void> saveLevelPosition(String level, int index) =>
      DBHelper.saveLevelPosition(level, index);

  @override
  Future<String?> getLastTrainingLevel() => DBHelper.getLastTrainingLevel();
}
