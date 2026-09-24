part of listening;

class ListeningResultView extends StatelessWidget {
  final ListeningComplete state;
  final VoidCallback onTryAgain;

  const ListeningResultView({
    super.key,
    required this.state,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final double percentage =
        (state.score / state.totalQuestions) * 100;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: Dimensions.itemHeight88,
              height: Dimensions.itemHeight88,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${state.score}/${state.totalQuestions}',
                  style: AppTextStyles.scoreDisplay(colors.primary),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.itemHeight16),
            Text(
              _titleForScore(percentage),
              style: AppTextStyles.titleXLarge(colors.textPrimary),
            ),
            const SizedBox(height: Dimensions.itemHeight8),
            Text(
              _messageForScore(percentage),
              style: AppTextStyles.bodyMedium(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.itemHeight28),
            GestureDetector(
              onTap: onTryAgain,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.padding12,
                  horizontal: Dimensions.padding26,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadiusPill),
                ),
                child: Text(
                  'quiz.try_again'.tr(),
                  style: AppTextStyles.labelLarge(colors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleForScore(double p) {
    if (p >= 90) return 'quiz.results.title_excellent'.tr();
    if (p >= 70) return 'quiz.results.title_great'.tr();
    if (p >= 50) return 'quiz.results.title_good'.tr();
    return 'quiz.results.title_keep_trying'.tr();
  }

  String _messageForScore(double p) {
    if (p >= 90) return 'quiz.results.excellent'.tr();
    if (p >= 70) return 'quiz.results.great'.tr();
    if (p >= 50) return 'quiz.results.good'.tr();
    return 'quiz.results.keep_trying'.tr();
  }
}
