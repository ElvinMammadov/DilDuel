/// The training levels, in display order.
const List<String> trainingLevels = <String>['A1', 'A2', 'B1', 'B2'];

/// Contract for persisting per-level training progress.
abstract class TrainingProgressRepository {
  /// Returns the saved word index for [level], or 0 if never set.
  Future<int> getLevelPosition(String level);

  /// Persists [index] for [level].
  Future<void> saveLevelPosition(String level, int index);

  /// Returns the most recently accessed level, or `null` if none.
  Future<String?> getLastTrainingLevel();

  /// Sends any positions still waiting to be synced to remote storage.
  /// A no-op for repositories that write through immediately.
  Future<void> flush();
}
