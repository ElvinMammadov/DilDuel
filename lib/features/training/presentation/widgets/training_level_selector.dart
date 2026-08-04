part of training;

// ── Level colour helpers ───────────────────────────────────────────────────

Color _levelFg(String level, bool isDark) {
  switch (level) {
    case 'A1':
      return isDark ? AppTheme.successColorDark : AppTheme.successColor;
    case 'A2':
      return isDark ? AppTheme.accentColorDark : AppTheme.accentColor;
    case 'B1':
      return AppTheme.warningColor;
    case 'B2':
      return isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    default:
      return isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
  }
}

Color _levelBg(String level, bool isDark) {
  switch (level) {
    case 'A1':
      return isDark ? AppTheme.successTintDark : AppTheme.successTint;
    case 'A2':
      return isDark ? AppTheme.accentColorDark.withValues(alpha: 0.18) : AppTheme.warningTint;
    case 'B1':
      return isDark ? AppTheme.errorTintDark : AppTheme.errorTint;
    case 'B2':
      return isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    default:
      return isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
  }
}

// ── Dropdown widget ────────────────────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  final String? selectedLevel;

  const _LevelSelector({this.selectedLevel});

  static const List<String> _levels = <String>['A1', 'A2', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.padding8,
        horizontal: Dimensions.padding16,
      ),
      child: AppDropdown<String>(
        onSelected: (String level) =>
            context.read<TrainingCubit>().loadLevel(level),
        itemsBuilder: (BuildContext ctx) {
          final bool dark = Theme.of(ctx).brightness == Brightness.dark;
          final Color tp =
              dark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
          final Color ts =
              dark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
          final Color bd =
              dark ? AppTheme.borderDark : AppTheme.borderLight;
          final TrainingCubit cubit = ctx.read<TrainingCubit>();

          return <PopupMenuEntry<String>>[
            for (int i = 0; i < _levels.length; i++) ...<PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: _levels[i],
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.padding16,
                  vertical: Dimensions.padding8,
                ),
                child: _menuItem(_levels[i], tp, ts, dark, cubit),
              ),
              if (i < _levels.length - 1)
                PopupMenuDivider(height: 1, color: bd),
            ],
          ];
        },
        child: _buildSelectedRow(textPrimary, textSecondary, isDark),
      ),
    );
  }

  Widget _buildSelectedRow(
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    if (selectedLevel == null) {
      return Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'training.choose_level'.tr(),
              style: AppTextStyles.bodyLarge(textSecondary),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Text(
          'training.level'.tr(),
          style: AppTextStyles.titleSmall(textPrimary),
        ),
        const SizedBox(width: Dimensions.itemWidth12),
        _LevelBadge(level: selectedLevel!, isDark: isDark),
        const Spacer(),
        Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
      ],
    );
  }

  Widget _menuItem(
    String level,
    Color textColor,
    Color textSecondary,
    bool isDark,
    TrainingCubit cubit,
  ) =>
      Row(
        children: <Widget>[
          Text(
            'training.level'.tr(),
            style: AppTextStyles.bodyLarge(textColor),
          ),
          const SizedBox(width: Dimensions.itemWidth12),
          _LevelBadge(level: level, isDark: isDark),
          const Spacer(),
          _LevelProgress(
            level: level,
            cubit: cubit,
            textColor: textSecondary,
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
    final Color fg = _levelFg(
      level,
      Theme.of(context).brightness == Brightness.dark,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(label, style: AppTextStyles.caption(textColor)),
        const SizedBox(height: 3),
        SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
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
  final bool isDark;

  const _LevelBadge({required this.level, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _levelBg(level, isDark),
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        ),
        child: Text(
          level,
          style: AppTextStyles.labelMedium(_levelFg(level, isDark)),
        ),
      );
}
