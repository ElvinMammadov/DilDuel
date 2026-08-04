part of training;

/// Shown before the user picks a level.
class _TrainingEmptyState extends StatelessWidget {
  const _TrainingEmptyState();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: primary,
              ),
            ),
            const SizedBox(height: Dimensions.itemHeight20),
            Text(
              'training.empty_title'.tr(),
              style: AppTextStyles.titleLarge(textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.itemHeight8),
            Text(
              'training.empty_subtitle'.tr(),
              style: AppTextStyles.bodyMedium(textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

