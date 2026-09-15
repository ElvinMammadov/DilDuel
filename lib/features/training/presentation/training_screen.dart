part of training;

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<TrainingCubit>(
        create: (_) => sl<TrainingCubit>()..init(),
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              (previous is AuthAuthenticated &&
                  current is AuthUnauthenticated) ||
              (previous is AuthUnauthenticated && current is AuthAuthenticated),
          listener: (BuildContext context, AuthState state) {
            final TrainingCubit cubit = context.read<TrainingCubit>();
            if (state is AuthUnauthenticated) {
              // Sign-out: local data was already cleared, so reset the
              // in-memory cache and reload (will come back empty).
              cubit.reset();
            } else if (state is AuthAuthenticated) {
              // Sign-in: the sign-in merge has already completed by the
              // time this state is emitted, so reload to pick up the
              // signed-in user's own synced progress.
              cubit.init();
            }
          },
          child: const _TrainingView(),
        ),
      );
}

class _TrainingView extends StatelessWidget {
  const _TrainingView();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TrainingCubit, TrainingState>(
        builder: (BuildContext context, TrainingState state) {
          final String? selectedLevel = state is TrainingReady
              ? state.level
              : (state is TrainingLoading ? state.level : null);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _LevelSelector(selectedLevel: selectedLevel),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails details) {
                    final double? v = details.primaryVelocity;
                    if (v == null) return;
                    if (v < -400) {
                      context.read<TrainingCubit>().next();
                    } else if (v > 400) {
                      context.read<TrainingCubit>().previous();
                    }
                  },
                  child: _buildBody(context, state),
                ),
              ),
            ],
          );
        },
      );

  Widget _buildBody(BuildContext context, TrainingState state) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is TrainingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TrainingError) {
      return Center(
        child: Text(
          state.message,
          style: AppTextStyles.bodyMedium(
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state is TrainingReady) {
      return Column(
        children: <Widget>[
          Expanded(child: _TrainingWordCard(state: state)),
          _TrainingNavButtons(state: state),
        ],
      );
    }

    return EmptyStateView(
      icon: Icons.menu_book_rounded,
      color: isDark ? AppTheme.mainColorDark : AppTheme.mainColor,
      tintColor: isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint,
      title: 'training.empty_title'.tr(),
      description: 'training.empty_subtitle'.tr(),
    );
  }
}
