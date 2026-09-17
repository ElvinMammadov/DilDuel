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
              vertical: Dimensions.padding20),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            border: Border.all(color: colors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          ),
          child: Text(
            widget.word.question,
            style: AppTextStyles.wordSource(colors.textPrimary, size: 18),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.itemHeight20),
        // Answer options
        ...widget.word.options.map((String option) {
          final bool isSelected = selectedAnswer == option;
          final bool isCorrect = widget.word.correctAnswer == option;

          Color bg = colors.surface;
          Color textColor = colors.textPrimary;
          Color borderColor = colors.border;

          if (showAnswer) {
            if (isCorrect) {
              bg = colors.successTint;
              textColor = colors.success;
              borderColor = colors.success;
            } else if (isSelected) {
              bg = colors.errorTint;
              textColor = colors.error;
              borderColor = colors.error;
            } else {
              textColor = colors.textSecondary;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.padding10),
            child: GestureDetector(
              onTap: showAnswer ? null : () => _handleAnswer(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.padding10,
                    horizontal: Dimensions.padding16),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                ),
                child: Text(
                  option,
                  style: AppTextStyles.labelLarge(textColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
        if (showAnswer) ...<Widget>[
          const SizedBox(height: Dimensions.itemHeight10),
          GestureDetector(
            onTap: _handleContinue,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.padding14),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
              child: Text(
                'quiz.next'.tr(),
                style:
                    AppTextStyles.titleSmall(colors.onPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
