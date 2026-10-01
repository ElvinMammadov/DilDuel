part of training;

// ── Level colour helpers ──────────────────────────────────────────────────

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

Color _levelCardColor(String level, AppColors colors) {
  switch (level) {
    case 'A1':
      return colors.levelA1;
    case 'A2':
      return colors.levelA2;
    case 'B1':
      return colors.levelB1;
    default:
      return colors.levelB2;
  }
}

// ── Level cards grid ──────────────────────────────────────────────────────

class _LevelCardsGrid extends StatelessWidget {
  const _LevelCardsGrid();

  static const List<String> _levels = <String>['A1', 'A2', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    final TrainingCubit cubit = context.read<TrainingCubit>();
    return AppFilledCardList(
      children: <Widget>[
        for (final String level in _levels)
          _LevelCard(level: level, cubit: cubit),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final TrainingCubit cubit;

  const _LevelCard({required this.level, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final int total = cubit.levelTotals[level] ?? 0;
    final int saved = cubit.savedIndices[level] ?? 0;

    return AppFilledCard(
      color: _levelCardColor(level, colors),
      onTap: () => context.read<TrainingCubit>().loadLevel(level),
      watermark: _LevelWatermark(level: level),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _LevelInfo(level: level, saved: saved, total: total),
          ),
          if (total > 0) _CircularLevelProgress(value: (saved + 1) / total),
        ],
      ),
    );
  }
}

class _LevelInfo extends StatelessWidget {
  final String level;
  final int saved;
  final int total;

  const _LevelInfo({
    required this.level,
    required this.saved,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final Color onPrimary = AppColors.of(context).onPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(level, style: AppTextStyles.titleLarge(onPrimary)),
        if (total > 0)
          Text(
            '$saved / $total',
            style: AppTextStyles.caption(onPrimary.withValues(alpha: 0.70)),
          ),
      ],
    );
  }
}

class _LevelWatermark extends StatelessWidget {
  final String level;

  const _LevelWatermark({required this.level});

  @override
  Widget build(BuildContext context) => Text(
        level,
        style: AppTextStyles.headlineLarge(
          AppColors.of(context).onPrimary.withValues(alpha: 0.10),
        ).copyWith(
          fontSize: Dimensions.itemHeight88,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      );
}

class _CircularLevelProgress extends StatelessWidget {
  final double value;

  const _CircularLevelProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    final Color onPrimary = AppColors.of(context).onPrimary;
    return SizedBox(
      width: Dimensions.itemHeight50,
      height: Dimensions.itemHeight50,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 3.5,
              strokeCap: StrokeCap.round,
              backgroundColor: onPrimary.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(onPrimary),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: AppTextStyles.caption(onPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Back bar shown when a level is active ─────────────────────────────────

class _LevelBackBar extends StatelessWidget {
  final String? level;

  const _LevelBackBar({this.level});

  @override
  Widget build(BuildContext context) => AppBackBar(
        onBack: () => context.read<TrainingCubit>().backToLevels(),
        leading: level == null ? null : _LevelBadge(level: level!),
        label: level == null ? null : 'training.level'.tr(),
      );
}

// ── Level badge (used in back bar) ────────────────────────────────────────

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
