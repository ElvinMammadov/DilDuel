part of training;

abstract class TrainingState {}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingReady extends TrainingState {
  final List<Word> words;
  final int currentIndex;
  final String level;

  TrainingReady({
    required this.words,
    required this.currentIndex,
    required this.level,
  });

  Word get currentWord => words[currentIndex];
  int get total => words.length;
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == total - 1;

  TrainingReady copyWith({int? currentIndex}) => TrainingReady(
        words: words,
        currentIndex: currentIndex ?? this.currentIndex,
        level: level,
      );
}

class TrainingError extends TrainingState {
  final String message;
  TrainingError(this.message);
}

