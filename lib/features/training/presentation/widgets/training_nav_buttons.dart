part of training;

class _TrainingNavButtons extends StatelessWidget {
  final TrainingReady state;

  const _TrainingNavButtons({required this.state});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color primary = colors.primary;
    final Color border = colors.border;
    final Color surface = colors.surface;
    final Color disabledText = colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding16,
        Dimensions.padding16,
        Dimensions.padding16,
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
            onTap: state.total > 1
                ? () => JumpToWordSheet.show(context, state: state)
                : null,
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
        ? (filled ? AppColors.of(context).onPrimary : primary)
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
              Icon(icon, size: Dimensions.itemHeight18, color: fg),
              const SizedBox(width: Dimensions.itemWidth6),
            ],
            Text(label, style: AppTextStyles.labelLarge(fg)),
            if (filled) ...<Widget>[
              const SizedBox(width: Dimensions.itemWidth6),
              Icon(icon, size: Dimensions.itemHeight18, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact animated progress bar with a tappable word counter below it.
///
/// Tapping opens the "jump to word" sheet when [onTap] is provided.
class _TrainingProgressBar extends StatelessWidget {
  final int total;
  final int current;
  final Color primary;
  final Color border;
  final VoidCallback? onTap;

  const _TrainingProgressBar({
    required this.total,
    required this.current,
    required this.primary,
    required this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double value = total <= 1 ? 1.0 : current / (total - 1);
    return Semantics(
      button: onTap != null,
      label: 'training.jump.hint'.tr(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.padding8),
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minWidth: Dimensions.itemWidth64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.itemHeight4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: value),
                      duration: const Duration(milliseconds: 300),
                      builder: (BuildContext ctx, double v, Widget? _) =>
                          LinearProgressIndicator(
                        value: v,
                        minHeight: Dimensions.itemHeight6,
                        backgroundColor: border.a < 0.32
                            ? border.withValues(alpha: 0.32)
                            : border,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.padding6),
                  _CounterPill(
                    text: '${current + 1} / $total',
                    color: primary,
                    showIcon: onTap != null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.text,
    required this.color,
    required this.showIcon,
  });

  final String text;
  final Color color;
  final bool showIcon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.of(context).primaryTint,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding8,
            vertical: Dimensions.padding2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(text, style: AppTextStyles.caption(color)),
              if (showIcon) ...<Widget>[
                const SizedBox(width: Dimensions.itemWidth2),
                Icon(
                  Icons.unfold_more_rounded,
                  size: Dimensions.itemHeight14,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      );
}
