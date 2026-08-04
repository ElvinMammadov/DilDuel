part of training;

/// Cubit that manages the training session lifecycle.
///
/// All progress is stored in the [DBHelper.trainingLevelPosition] table so
/// every level's position is persisted independently and the DB is the single
/// source of truth — no SharedPreferences are used.
class TrainingCubit extends Cubit<TrainingState> {
  static const List<String> _allLevels = <String>['A1', 'A2', 'B1', 'B2'];

  /// Saved word index for every level (in-memory cache, loaded on [init]).
  final Map<String, int> savedIndices = <String, int>{};

  /// Total word count for every level (populated on [init]).
  final Map<String, int> levelTotals = <String, int>{};

  TrainingCubit() : super(TrainingInitial());

  /// Loads per-level stats from the DB and restores the last active session.
  Future<void> init() async {
    // Load saved positions and word counts for every level in parallel.
    await Future.wait(
      _allLevels.map((String l) async {
        savedIndices[l] = await DBHelper.getLevelPosition(l);
        levelTotals[l] = await DBHelper.getWordCountByLevel(l);
      }),
    );

    // Rebuild the dropdown with fresh stats.
    emit(TrainingInitial());

    // Restore the most recently active level.
    final String? lastLevel = await DBHelper.getLastTrainingLevel();
    if (lastLevel != null) {
      await _doLoad(lastLevel, startIndex: savedIndices[lastLevel] ?? 0);
    }
  }

  /// Loads words for [level], resuming from the previously saved position.
  Future<void> loadLevel(String level) async {
    final int savedIndex = savedIndices[level] ?? 0;
    await _doLoad(level, startIndex: savedIndex);
  }

  Future<void> _doLoad(String level, {required int startIndex}) async {
    emit(TrainingLoading());
    try {
      final List<Word> words = await DBHelper.getWordsByLevel(level);
      if (words.isEmpty) {
        emit(TrainingError('training.no_words'.tr()));
        return;
      }
      final int index = startIndex.clamp(0, words.length - 1);
      await _persist(level, index);
      emit(TrainingReady(words: words, currentIndex: index, level: level));
    } catch (e) {
      emit(TrainingError(e.toString()));
    }
  }

  /// Advances to the next word and persists the new position.
  Future<void> next() async {
    if (state is! TrainingReady) return;
    final TrainingReady s = state as TrainingReady;
    if (s.isLast) return;
    final int newIndex = s.currentIndex + 1;
    await _persist(s.level, newIndex);
    emit(s.copyWith(currentIndex: newIndex));
  }

  /// Goes back to the previous word and persists the new position.
  Future<void> previous() async {
    if (state is! TrainingReady) return;
    final TrainingReady s = state as TrainingReady;
    if (s.isFirst) return;
    final int newIndex = s.currentIndex - 1;
    await _persist(s.level, newIndex);
    emit(s.copyWith(currentIndex: newIndex));
  }

  Future<void> _persist(String level, int index) async {
    savedIndices[level] = index;
    await DBHelper.saveLevelPosition(level, index);
  }
}
