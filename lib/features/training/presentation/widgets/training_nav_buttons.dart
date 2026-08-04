part of training;

class _TrainingNavButtons extends StatelessWidget {
  final TrainingReady state;

  const _TrainingNavButtons({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary =
        isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color border =
        isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color surface =
        isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color disabledText =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding20,
        Dimensions.padding16,
        Dimensions.padding20,
        Dimensions.padding20,
      ),
      child: Row(
        children: <Widget>[
          // ── Back button ───────────────────────────────────────────
          Expanded(
            child: _NavButton(
              icon: Icons.arrow_back_rounded,
              label: 'training.back'.tr(),
              enabled: !state.isFirst,
              filled: false,
              primary: primary,
              surface: surface,
              border: border,
              disabledText: disabledText,
              onTap: () => context.read<TrainingCubit>().previous(),
            ),
          ),
          const SizedBox(width: Dimensions.itemWidth16),
          // ── Progress bar ──────────────────────────────────────────
          _TrainingProgressBar(
            total: state.total,
            current: state.currentIndex,
            primary: primary,
            border: border,
          ),
          const SizedBox(width: Dimensions.itemWidth16),
          // ── Forward button ────────────────────────────────────────
          Expanded(
            child: _NavButton(
              icon: Icons.arrow_forward_rounded,
              label: 'training.next'.tr(),
              enabled: !state.isLast,
              filled: true,
              primary: primary,
              surface: surface,
              border: border,
              disabledText: disabledText,
              onTap: () => context.read<TrainingCubit>().next(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool filled;
  final Color primary;
  final Color surface;
  final Color border;
  final Color disabledText;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.filled,
    required this.primary,
    required this.surface,
    required this.border,
    required this.disabledText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = enabled
        ? (filled ? Colors.white : primary)
        : disabledText;
    final Color bg = enabled
        ? (filled ? primary : surface)
        : (filled ? disabledText.withAlpha(40) : Colors.transparent);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: Dimensions.itemHeight44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
          border: filled ? null : Border.all(color: enabled ? primary : border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!filled) ...<Widget>[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: Dimensions.itemWidth6),
            ],
            Text(label, style: AppTextStyles.labelLarge(fg)),
            if (filled) ...<Widget>[
              const SizedBox(width: Dimensions.itemWidth6),
              Icon(icon, size: 18, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact animated progress bar with word counter below it.
class _TrainingProgressBar extends StatelessWidget {
  final int total;
  final int current;
  final Color primary;
  final Color border;

  const _TrainingProgressBar({
    required this.total,
    required this.current,
    required this.primary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final double value = total <= 1 ? 1.0 : current / (total - 1);
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 300),
              builder: (BuildContext ctx, double v, Widget? _) =>
                  LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: border.a < 0.32
                    ? border.withValues(alpha: 0.32)
                    : border,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${current + 1} / $total',
            style: AppTextStyles.caption(primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
