part of quiz;

/// A widget that displays a single quiz question with multiple choice answers
class QuizQuestion extends StatefulWidget {
  final QuizWord word;
  final Function(String) onAnswer;
  final bool? lastAnswerCorrect;

  const QuizQuestion({
    super.key,
    required this.word,
    required this.onAnswer,
    this.lastAnswerCorrect,
  });

  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  String? selectedAnswer;
  bool showAnswer = false;

  void _handleAnswer(String answer) {
    if (showAnswer) return;
    setState(() {
      selectedAnswer = answer;
      showAnswer = true;
    });
  }

  void _handleContinue() {
    if (selectedAnswer == null) return;
    widget.onAnswer(selectedAnswer!);
    setState(() {
      selectedAnswer = null;
      showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppCard(
                elevation: Dimensions.itemHeight2,
                backgroundColor: AppTheme.mainColor.withAlpha(13),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.itemHeight8),
                  side: BorderSide(
                    color: AppTheme.mainColor.withAlpha(77),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding16),
                  child: Text(
                    widget.word.question,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: AppTheme.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.padding20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...widget.word.options.map((String option) {
                      final bool isSelected = selectedAnswer == option;
                      final bool isCorrect =
                          widget.word.correctAnswer == option;

                      final Color buttonColor = showAnswer
                          ? (isCorrect
                              ? AppTheme.successColor.withAlpha(26)
                              : (isSelected
                                  ? AppTheme.errorColor.withAlpha(26)
                                  : Colors.white))
                          : Colors.white;

                      final Color textColor = showAnswer
                          ? (isCorrect
                              ? AppTheme.successColor
                              : (isSelected
                                  ? AppTheme.errorColor
                                  : AppTheme.textPrimaryLight))
                          : AppTheme.textPrimaryLight;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.padding8,
                        ),
                        child: AppElevatedButton(
                          text: option,
                          backgroundColor: buttonColor,
                          textColor: textColor,
                          onPressed: showAnswer
                              ? () {}
                              : () => _handleAnswer(option),
                        ),
                      );
                    }),
                    if (showAnswer)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.padding20),
                        child: AppElevatedButton(
                          text: 'Continue',
                          backgroundColor: AppTheme.mainColor,
                          textColor: Colors.white,
                          onPressed: _handleContinue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
}
