part of quiz;

/// Base class for all quiz states
abstract class QuizState {}

/// Initial state before the quiz starts
class QuizInitial extends QuizState {}

/// State while quiz questions are being loaded
class QuizLoading extends QuizState {}

/// State when an error occurs during quiz
class QuizError extends QuizState {
  /// Error message to display
  final String message;
  
  /// Creates a new [QuizError] state with the given error message
  QuizError(this.message);
}

/// State during an active quiz session
class QuizInProgress extends QuizState {
  /// List of all quiz words for this session
  final List<QuizWord> words;
  
  /// Index of the current question (0-based)
  final int currentIndex;
  
  /// Current score (number of correct answers)
  final int score;
  
  /// Whether the last answer was correct (null if no answer yet)
  final bool? lastAnswerCorrect;

  /// Creates a new [QuizInProgress] state
  QuizInProgress({
    required this.words,
    required this.currentIndex,
    required this.score,
    this.lastAnswerCorrect,
  });

  /// Whether all questions have been answered
  bool get isComplete => currentIndex >= words.length;

  /// Creates a copy of this state with optional parameter updates
  QuizInProgress copyWith({
    List<QuizWord>? words,
    int? currentIndex,
    int? score,
    bool? lastAnswerCorrect,
  }) => QuizInProgress(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      lastAnswerCorrect: lastAnswerCorrect,
    );
}

/// State when the quiz is completed
class QuizComplete extends QuizState {
  /// Total number of questions in the quiz
  final int totalQuestions;
  
  /// Final score (number of correct answers)
  final int score;

  /// Creates a new [QuizComplete] state with the final results
  QuizComplete({
    required this.totalQuestions,
    required this.score,
  });
} 