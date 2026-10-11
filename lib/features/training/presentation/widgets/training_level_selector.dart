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
    case 'C1':
      return colors.info;
    case 'C2':
      return colors.error;
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
    case 'C1':
      return colors.infoTint;
    case 'C2':
      return colors.errorTint;
    default:
      return colors.primaryTint;
  }
}

// ── Level cards grid ──────────────────────────────────────────────────────

class _LevelCardsGrid extends StatelessWidget {
  const _LevelCardsGrid();

  @override
  Widget build(BuildContext context) {
    final TrainingCubit cubit = context.read<TrainingCubit>();
    return AppFilledCardList(
      children: <Widget>[
        for (final String level in trainingLevels)
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
    final int total = cubit.levelTotals[level] ?? 0;
    final int saved = cubit.savedIndices[level] ?? 0;

    return AppFilledCard(
      onTap: () => context.read<TrainingCubit>().loadLevel(level),
      watermark: _LevelWatermark(level: level),
      child: Row(
        children: <Widget>[
          if (total > 0) ...<Widget>[
            _CircularLevelProgress(value: (saved + 1) / total),
            const SizedBox(width: Dimensions.padding16),
          ],
          Expanded(
            child: _LevelInfo(level: level, saved: saved, total: total),
          ),
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
    final Color primary = AppColors.of(context).primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(level, style: AppTextStyles.titleLarge(primary)),
        if (total > 0)
          Text(
            '$saved / $total',
            style: AppTextStyles.caption(primary.withValues(alpha: 0.70)),
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
          AppColors.of(context).primary.withValues(alpha: 0.08),
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
    final Color primary = AppColors.of(context).primary;
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
              backgroundColor: primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: AppTextStyles.caption(primary),
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
