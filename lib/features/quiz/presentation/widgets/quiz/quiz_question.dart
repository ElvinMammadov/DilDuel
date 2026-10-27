part of quiz;

/// A widget that displays a single quiz question with multiple choice answers
class QuizQuestion extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Question card
        Container(
          margin: const EdgeInsets.only(top: Dimensions.padding16),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding20,
            vertical: Dimensions.padding20,
          ),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            border: Border.all(
              color: colors.primary,
              width: Dimensions.borderWidthEmphasis,
            ),
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          ),
          child: Text(
            word.question,
            style: AppTextStyles.wordSource(colors.textPrimary, size: 18),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.itemHeight20),
        AnswerOptions(
          options: word.options,
          correctAnswer: word.correctAnswer,
          onAnswer: onAnswer,
        ),
      ],
    );
  }
}
