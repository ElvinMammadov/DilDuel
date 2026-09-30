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


// ── Level cards grid ──────────────────────────────────────────────────────

class _LevelCardsGrid extends StatelessWidget {
  const _LevelCardsGrid();

  static const List<String> _levels = <String>['A1', 'A2', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final TrainingCubit cubit = context.read<TrainingCubit>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'training.choose_level'.tr(),
            style: AppTextStyles.titleLarge(colors.textPrimary),
          ),
          const SizedBox(height: Dimensions.padding16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: Dimensions.padding12,
            mainAxisSpacing: Dimensions.padding12,
            childAspectRatio: 0.9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _levels
                .map((String l) => _LevelCard(level: l, cubit: cubit))
                .toList(),
          ),
        ],
      ),
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
    final Color fg = _levelFg(level, colors);
    final int total = cubit.levelTotals[level] ?? 0;
    final int saved = cubit.savedIndices[level] ?? 0;
    final double pct = total > 0 ? (saved + 1) / total : 0.0;

    return GestureDetector(
      onTap: () => context.read<TrainingCubit>().loadLevel(level),
      child: Container(
        decoration: BoxDecoration(
          color: fg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: fg.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            // Decorative watermark — oversized level code
            Positioned(
              right: -Dimensions.padding8,
              bottom: -Dimensions.padding20,
              child: Text(
                level,
                style: AppTextStyles.headlineLarge(
                  Colors.white.withValues(alpha: 0.10),
                ).copyWith(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.padding16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Frosted pill chip
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(
                        Dimensions.borderRadiusPill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.padding10,
                        vertical: Dimensions.padding3,
                      ),
                      child: Text(
                        level,
                        style: AppTextStyles.labelMedium(Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (total > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${(pct * 100).round()}%',
                              style: AppTextStyles.titleLarge(Colors.white),
                            ),
                            Text(
                              '$saved / $total',
                              style: AppTextStyles.caption(
                                Colors.white.withValues(alpha: 0.70),
                              ),
                            ),
                          ],
                        ),
                      if (total > 0) _CircularLevelProgress(value: pct),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularLevelProgress extends StatelessWidget {
  final double value;

  const _CircularLevelProgress({required this.value});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: Dimensions.itemHeight40,
        height: Dimensions.itemHeight40,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: 3.5,
          strokeCap: StrokeCap.round,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
}

// ── Back bar shown when a level is active ─────────────────────────────────

class _LevelBackBar extends StatelessWidget {
  final String? level;

  const _LevelBackBar({this.level});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding4,
        vertical: Dimensions.padding4,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary,
              size: Dimensions.itemHeight20,
            ),
            onPressed: () => context.read<TrainingCubit>().backToLevels(),
          ),
          if (level != null) ...<Widget>[
            const SizedBox(width: Dimensions.padding4),
            _LevelBadge(level: level!),
            const SizedBox(width: Dimensions.padding8),
            Text(
              'training.level'.tr(),
              style: AppTextStyles.titleSmall(colors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
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
