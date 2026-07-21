part of quiz;

class QuizResultView extends StatelessWidget {
  final QuizComplete state;
  final VoidCallback onTryAgain;

  const QuizResultView({
    super.key,
    required this.state,
    required this.onTryAgain,
  });

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

    final int correctAnswers = state.score;
    final int totalQuestions = state.totalQuestions;
    final double percentage = (correctAnswers / totalQuestions) * 100;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Score circle
            Container(
              width: Dimensions.itemHeight88,
              height: Dimensions.itemHeight88,
              decoration:
                  BoxDecoration(color: primaryTint, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$correctAnswers/$totalQuestions',
                  style: AppTextStyles.scoreDisplay(primary),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.itemHeight16),
            Text(
              _getTitleForScore(percentage),
              style: AppTextStyles.titleXLarge(textPrimary),
            ),
            const SizedBox(height: Dimensions.itemHeight8),
            Text(
              _getMessageForScore(percentage),
              style: AppTextStyles.bodyMedium(textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.itemHeight28),
            GestureDetector(
              onTap: onTryAgain,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.padding12,
                    horizontal: Dimensions.padding26),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadiusPill),
                ),
                child: Text(
                  'quiz.try_again'.tr(),
                  style:
                      AppTextStyles.labelLarge(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleForScore(double percentage) {
    if (percentage >= 90) return 'quiz.results.title_excellent'.tr();
    if (percentage >= 70) return 'quiz.results.title_great'.tr();
    if (percentage >= 50) return 'quiz.results.title_good'.tr();
    return 'quiz.results.title_keep_trying'.tr();
  }

  String _getMessageForScore(double percentage) {
    if (percentage >= 90) {
      return 'quiz.results.excellent'.tr();
    }
    if (percentage >= 70) {
      return 'quiz.results.great'.tr();
    }
    if (percentage >= 50) {
      return 'quiz.results.good'.tr();
    }
    return 'quiz.results.keep_trying'.tr();
  }
}
