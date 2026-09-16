part of training;

// ── Level colour helpers ───────────────────────────────────────────────────

Color _levelFg(String level, AppColors colors) {
  switch (level) {
    case 'A1':
      return colors.success;
    case 'A2':
      return colors.accent;
    case 'B1':
      return colors.warning;
    case 'B2':
      return colors.primary;
    default:
      return colors.primary;
  }
}

Color _levelBg(String level, AppColors colors, bool isDark) {
  switch (level) {
    case 'A1':
      return colors.successTint;
    case 'A2':
      return isDark
          ? colors.accent.withValues(alpha: 0.18)
          : colors.warningTint;
    case 'B1':
      return colors.errorTint;
    case 'B2':
      return colors.primaryTint;
    default:
      return colors.primaryTint;
  }
}

// ── Dropdown widget ────────────────────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  final String? selectedLevel;

  const _LevelSelector({this.selectedLevel});

  static const List<String> _levels = <String>['A1', 'A2', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.padding8,
        horizontal: Dimensions.padding16,
      ),
      child: AppDropdown<String>(
        onSelected: (String level) =>
            context.read<TrainingCubit>().loadLevel(level),
        itemsBuilder: (BuildContext ctx) {
          final AppColors ctxColors = AppColors.of(ctx);
          final TrainingCubit cubit = ctx.read<TrainingCubit>();

          return <PopupMenuEntry<String>>[
            for (int i = 0; i < _levels.length; i++) ...<PopupMenuEntry<String>
            >[
              PopupMenuItem<String>(
                value: _levels[i],
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.padding16,
                  vertical: Dimensions.padding8,
                ),
                child: _menuItem(_levels[i], ctxColors, cubit),
              ),
              if (i < _levels.length - 1)
                PopupMenuDivider(height: 1, color: ctxColors.border),
            ],
          ];
        },
        child: _buildSelectedRow(colors),
      ),
    );
  }

  Widget _buildSelectedRow(AppColors colors) {
    if (selectedLevel == null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'training.choose_level'.tr(),
              style: AppTextStyles.bodyLarge(colors.textSecondary),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.textSecondary,
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Text(
          'training.level'.tr(),
          style: AppTextStyles.titleSmall(colors.textPrimary),
        ),
        const SizedBox(width: Dimensions.itemWidth12),
        _LevelBadge(level: selectedLevel!),
        const Spacer(),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _menuItem(String level, AppColors colors, TrainingCubit cubit) =>
      Row(
        children: <Widget>[
          Text(
            'training.level'.tr(),
            style: AppTextStyles.bodyLarge(colors.textPrimary),
          ),
          const SizedBox(width: Dimensions.itemWidth12),
          _LevelBadge(level: level),
          const Spacer(),
          _LevelProgress(
            level: level,
            cubit: cubit,
            textColor: colors.textSecondary,
            compact: false,
          ),
        ],
      );
}

// ── Progress label ─────────────────────────────────────────────────────────

class _LevelProgress extends StatelessWidget {
  final String level;
  final TrainingCubit cubit;
  final Color textColor;

  /// [compact] true = show only "5/666", false = show mini bar + count.
  final bool compact;

  const _LevelProgress({
    required this.level,
    required this.cubit,
    required this.textColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final int total = cubit.levelTotals[level] ?? 0;
    final int saved = cubit.savedIndices[level] ?? 0;
    if (total == 0) return const SizedBox.shrink();

    final String label = '${saved + 1} / $total';

    if (compact) {
      return Text(label, style: AppTextStyles.caption(textColor));
    }

    // Full: mini bar + counter
    final double pct = (saved + 1) / total;
    final AppColors colors = AppColors.of(context);
    final Color fg = _levelFg(level, colors);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(label, style: AppTextStyles.caption(textColor)),
        const SizedBox(height: Dimensions.padding3),
        SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: Dimensions.itemHeight4,
              backgroundColor: textColor.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Level badge ────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: Dimensions.itemWidth40,
      height: Dimensions.itemHeight26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _levelBg(level, colors, isDark),
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: Text(
        level,
        style: AppTextStyles.labelMedium(_levelFg(level, colors)),
      ),
    );
  }
}
