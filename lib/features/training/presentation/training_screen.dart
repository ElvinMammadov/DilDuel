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
              (current is AuthAuthenticated && previous is! AuthAuthenticated),
          listener: (BuildContext context, AuthState state) {
            final TrainingCubit cubit = context.read<TrainingCubit>();
            if (state is AuthUnauthenticated) {
              cubit.reset();
            } else if (state is AuthAuthenticated) {
              // Reload after sign-in: Firebase sync has already completed by
              // the time AuthAuthenticated is emitted, so init() will read
              // the already-merged local DB (covers app-restart, normal
              // sign-in, and the guest-data decision flow).
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
          if (state is TrainingInitial) {
            return const _LevelCardsGrid();
          }

          if (state is TrainingLoading) {
            return Column(
              children: <Widget>[
                _LevelBackBar(level: state.level),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (state is TrainingError) {
            return Column(
              children: <Widget>[
                const _LevelBackBar(),
                Expanded(
                  child: Center(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(
                        AppColors.of(context).textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is TrainingReady) {
            return Column(
              children: <Widget>[
                _LevelBackBar(level: state.level),
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
                    child: Column(
                      children: <Widget>[
                        Expanded(child: _TrainingWordCard(state: state)),
                        _TrainingNavButtons(state: state),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const _LevelCardsGrid();
        },
      );
}
