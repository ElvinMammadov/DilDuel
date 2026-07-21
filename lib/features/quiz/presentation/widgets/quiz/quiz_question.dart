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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color success =
        isDark ? AppTheme.successColorDark : AppTheme.successColor;
    final Color successTint =
        isDark ? AppTheme.successTintDark : AppTheme.successTint;
    final Color error = isDark ? AppTheme.errorColorDark : AppTheme.errorColor;
    final Color errorTint =
        isDark ? AppTheme.errorTintDark : AppTheme.errorTint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Question card
        Container(
          margin: const EdgeInsets.only(top: Dimensions.padding16),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding20,
              vertical: Dimensions.padding36),
          decoration: BoxDecoration(
            color: primaryTint,
            border: Border.all(color: primary, width: 1.5),
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMedium),
          ),
          child: Text(
            widget.word.question,
            style: AppTextStyles.wordSource(textPrimary, size: 24),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: Dimensions.itemHeight20),
        // Answer options
        ...widget.word.options.map((String option) {
          final bool isSelected = selectedAnswer == option;
          final bool isCorrect = widget.word.correctAnswer == option;

          Color bg = surface;
          Color textColor = textPrimary;
          Color borderColor = border;

          if (showAnswer) {
            if (isCorrect) {
              bg = successTint;
              textColor = success;
              borderColor = success;
            } else if (isSelected) {
              bg = errorTint;
              textColor = error;
              borderColor = error;
            } else {
              textColor = textSecondary;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.padding10),
            child: GestureDetector(
              onTap: showAnswer ? null : () => _handleAnswer(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.padding15,
                    horizontal: Dimensions.padding16),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                ),
                child: Text(
                  option,
                  style: AppTextStyles.bodyLargeBold(textColor),
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
                color: primary,
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
              child: Text(
                'quiz.next'.tr(),
                style:
                    AppTextStyles.titleSmall(Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
