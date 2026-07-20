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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Score circle
            Container(
              width: 88,
              height: 88,
              decoration:
                  BoxDecoration(color: primaryTint, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$correctAnswers/$totalQuestions',
                  style: AppTheme.titleLarge(primary).copyWith(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getTitleForScore(percentage),
              style: AppTheme.titleLarge(textPrimary).copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              _getMessageForScore(percentage),
              style: AppTheme.bodyMedium(textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onTryAgain,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusPill),
                ),
                child: Text(
                  'quiz.try_again'.tr(),
                  style:
                      AppTheme.titleMedium(Colors.white).copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleForScore(double percentage) {
    if (percentage >= 90) return 'Təbriklər!';
    if (percentage >= 70) return 'Əla nəticə!';
    if (percentage >= 50) return 'Yaxşı cəhd!';
    return 'Davam edin!';
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
