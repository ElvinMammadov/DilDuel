part of quiz;

/// BLoC for managing quiz state and logic
@injectable
class QuizBloc extends Cubit<QuizState> {
  /// Repository for fetching quiz words
  final QuizRepository repository;
  String? _currentDicType;

  /// Creates a new [QuizBloc] instance
  QuizBloc({required this.repository}) : super(QuizInitial());

  /// Starts a new quiz session with the given dictionary type
  ///
  /// [dicType] specifies which dictionary to use (e.g., 'AzDe' or 'DeAz')
  Future<void> startQuiz(String dicType) async {
    _currentDicType = dicType;
    emit(QuizLoading());
    final dartz.Either<Failure, List<QuizWord>> result =
        await repository.getQuizWords(dicType);

    result.fold(
      (Failure failure) => emit(QuizError('Failed to load quiz words')),
      (List<QuizWord> words) => emit(QuizInProgress(
        words: words,
        currentIndex: 0,
        score: 0,
      )),
    );
  }

  /// Processes a user's answer to the current question
  ///
  /// [answer] is the selected option
  ///
  /// Updates the score and moves to the next question or completes the quiz
  void answerQuestion(String answer) {
    if (state is! QuizInProgress) return;

    final QuizInProgress currentState = state as QuizInProgress;
    final QuizWord currentWord = currentState.words[currentState.currentIndex];
    final bool isCorrect = currentWord.correctAnswer == answer;

    final int newScore =
        isCorrect ? currentState.score + 1 : currentState.score;
    final int newIndex = currentState.currentIndex + 1;

    if (newIndex >= currentState.words.length) {
      // Save quiz result to database
      final QuizResult result = QuizResult(
        score: newScore,
        totalQuestions: currentState.words.length,
        dateTime: DateTime.now(),
      );
      DBHelper.insertQuizResult(result);

      emit(QuizComplete(
        totalQuestions: currentState.words.length,
        score: newScore,
      ));
    } else {
      emit(currentState.copyWith(
        currentIndex: newIndex,
        score: newScore,
        lastAnswerCorrect: isCorrect,
      ));
    }
  }

  /// Resets the quiz and starts a new one with fresh questions
  Future<void> resetQuiz() async {
    if (_currentDicType == null) {
      emit(QuizInitial());
      return;
    }

    emit(QuizLoading());
    final dartz.Either<Failure, List<QuizWord>> result =
        await repository.getQuizWords(_currentDicType!);

    result.fold(
      (Failure failure) => emit(QuizError('Failed to load quiz words')),
      (List<QuizWord> words) => emit(QuizInProgress(
        words: words,
        currentIndex: 0,
        score: 0,
      )),
    );
  }

  /// Cancels the current quiz and returns to the initial state
  void cancelQuiz() {
    _currentDicType = null;
    emit(QuizInitial());
  }
}
