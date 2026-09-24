part of listening;

@injectable
class ListeningCubit extends Cubit<ListeningState> {
  ListeningCubit(
    this._localDataSource,
    this._listeningResultRepository,
  ) : super(ListeningInitial());

  final WordLocalDataSource _localDataSource;
  final ListeningResultRepository _listeningResultRepository;
  final Random _random = Random();

  bool _isValidString(String? s) => s != null && s.trim().isNotEmpty;

  Future<void> startListening() async {
    emit(ListeningLoading());
    try {
      final List<Word> allWords =
          await _localDataSource.searchWords('', DBHelper.deAz);

      final List<Word> validWords = allWords
          .where((Word w) => _isValidString(w.key) && _isValidString(w.value))
          .toList();

      if (validWords.length < 4) {
        emit(ListeningError('listening.error_not_enough'.tr()));
        return;
      }

      validWords.shuffle(_random);
      final List<Word> wordsForSession = validWords.take(10).toList();
      final List<ListeningQuestion> questions = <ListeningQuestion>[];

      for (final Word word in wordsForSession) {
        final String correctAnswer = word.key;

        final List<String> wrongOptions = validWords
            .where((Word w) => w.key != word.key && _isValidString(w.key))
            .map((Word w) => w.key)
            .where((String k) => k != correctAnswer)
            .toList();

        if (wrongOptions.length < 3) continue;

        wrongOptions.shuffle(_random);
        final List<String> options = <String>[
          correctAnswer,
          ...wrongOptions.take(3),
        ]..shuffle(_random);

        questions.add(ListeningQuestion(
          word: word,
          correctAnswer: correctAnswer,
          options: options,
        ));
      }

      if (questions.length < 4) {
        emit(ListeningError('listening.error_not_enough'.tr()));
        return;
      }

      emit(ListeningInProgress(
        questions: questions,
        currentIndex: 0,
        score: 0,
      ));
    } catch (e) {
      emit(ListeningError(e.toString()));
    }
  }

  Future<void> answer(String selected) async {
    if (state is! ListeningInProgress) return;
    final ListeningInProgress current = state as ListeningInProgress;
    final ListeningQuestion question = current.currentQuestion;
    final bool isCorrect = question.correctAnswer == selected;

    if (isCorrect) {
      await DBHelper.addListenedWord(question.word);
    }

    final AnswerRecord answerRecord = AnswerRecord(
      question: question.word.value,
      correctAnswer: question.correctAnswer,
      givenAnswer: selected,
      isCorrect: isCorrect,
    );
    final List<AnswerRecord> newAnswers = <AnswerRecord>[
      ...current.answers,
      answerRecord,
    ];

    final int newScore = isCorrect ? current.score + 1 : current.score;
    final int newIndex = current.currentIndex + 1;

    if (newIndex >= current.questions.length) {
      final QuizResult result = QuizResult(
        score: newScore,
        totalQuestions: current.questions.length,
        dateTime: DateTime.now(),
        answers: newAnswers,
      );
      await _listeningResultRepository.insertListeningResult(result);
      emit(ListeningComplete(
        score: newScore,
        totalQuestions: current.questions.length,
      ));
    } else {
      emit(current.copyWith(
        currentIndex: newIndex,
        score: newScore,
        lastAnswerCorrect: isCorrect,
        answers: newAnswers,
      ));
    }
  }

  void cancel() => emit(ListeningInitial());
}
