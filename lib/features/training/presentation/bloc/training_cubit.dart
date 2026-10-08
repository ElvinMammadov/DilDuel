part of training;

/// Cubit that manages the training session lifecycle.
///
/// Progress (per-level word index) is stored via [TrainingProgressRepository],
/// which writes to local SQLite and syncs to Firestore when signed in.
@injectable
class TrainingCubit extends Cubit<TrainingState> {
  /// Saved word index for every level (in-memory cache, loaded on [init]).
  final Map<String, int> savedIndices = <String, int>{};

  /// Total word count for every level (populated on [init]).
  final Map<String, int> levelTotals = <String, int>{};

  /// Incremented each time [init] is called; lets concurrent calls
  /// detect that a newer call has superseded them and bail out early.
  int _initGeneration = 0;

  TrainingCubit(this._progressRepository) : super(TrainingInitial());

  final TrainingProgressRepository _progressRepository;

  /// Loads per-level stats from the DB and restores the last active session.
  Future<void> init() async {
    final int gen = ++_initGeneration;
    await Future.wait(
      trainingLevels.map((String l) async {
        savedIndices[l] = await _progressRepository.getLevelPosition(l);
        levelTotals[l] = await DBHelper.getWordCountByLevel(l);
      }),
    );
    if (gen != _initGeneration) return;

    emit(TrainingInitial());

    final String? lastLevel = await _progressRepository.getLastTrainingLevel();
    if (gen != _initGeneration) return;
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
    emit(TrainingLoading(level: level));
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

  /// Jumps straight to [index] (clamped to the level) and persists the new
  /// position once.
  Future<void> jumpTo(int index) async {
    final TrainingState s = state;
    if (s is! TrainingReady) return;
    final int target = index.clamp(0, s.total - 1);
    if (target == s.currentIndex) return;
    await _persist(s.level, target);
    emit(s.copyWith(currentIndex: target));
  }

  Future<void> _persist(String level, int index) async {
    savedIndices[level] = index;
    await _progressRepository.saveLevelPosition(level, index);
  }

  /// Returns to the level selection grid without clearing any progress.
  void backToLevels() {
    unawaited(_progressRepository.flush());
    emit(TrainingInitial());
  }

  /// Clears the in-memory progress cache and reloads it from storage.
  ///
  /// Call this on sign-out: without it, [savedIndices] and [levelTotals]
  /// keep holding the previous user's progress even after the underlying
  /// DB rows have been cleared, since this cubit lives for the app's
  /// entire lifetime inside the Training tab.
  Future<void> reset() async {
    savedIndices.clear();
    levelTotals.clear();
    // Emit immediately so _LevelCard rebuilds with zeroed maps before the
    // async DB reads in init() complete. Without this, old progress values
    // remain visible during the async gap.
    emit(TrainingInitial());
    await init();
  }
}
