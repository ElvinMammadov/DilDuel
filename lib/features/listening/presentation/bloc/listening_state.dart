part of listening;

abstract class ListeningState {}

class ListeningInitial extends ListeningState {}

class ListeningLoading extends ListeningState {}

class ListeningError extends ListeningState {
  final String message;

  ListeningError(this.message);
}

class ListeningInProgress extends ListeningState {
  final List<ListeningQuestion> questions;
  final int currentIndex;
  final int score;
  final bool? lastAnswerCorrect;
  final List<AnswerRecord> answers;

  ListeningInProgress({
    required this.questions,
    required this.currentIndex,
    required this.score,
    this.lastAnswerCorrect,
    List<AnswerRecord>? answers,
  }) : answers = answers ?? const <AnswerRecord>[];

  ListeningQuestion get currentQuestion => questions[currentIndex];

  ListeningInProgress copyWith({
    int? currentIndex,
    int? score,
    bool? lastAnswerCorrect,
    List<AnswerRecord>? answers,
  }) =>
      ListeningInProgress(
        questions: questions,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        lastAnswerCorrect: lastAnswerCorrect,
        answers: answers ?? this.answers,
      );
}

class ListeningComplete extends ListeningState {
  final int score;
  final int totalQuestions;

  ListeningComplete({required this.score, required this.totalQuestions});
}
