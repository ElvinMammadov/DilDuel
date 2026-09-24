part of listening;

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<ListeningCubit>(
        create: (_) => sl<ListeningCubit>(),
        child: const _ListeningView(),
      );
}

class _ListeningView extends StatelessWidget {
  const _ListeningView();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ListeningCubit, ListeningState>(
        builder: (BuildContext context, ListeningState state) {
          if (state is ListeningLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListeningError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.padding20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(
                          AppColors.of(context).textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.itemHeight16),
                    AppElevatedButton(
                      text: 'common.try_again'.tr(),
                      onPressed: () =>
                          context.read<ListeningCubit>().startListening(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ListeningInProgress) {
            return ListeningInProgressView(state: state);
          }

          if (state is ListeningComplete) {
            return ListeningResultView(
              state: state,
              onTryAgain: () =>
                  context.read<ListeningCubit>().startListening(),
            );
          }

          return ListeningInitialView(
            onStart: () =>
                context.read<ListeningCubit>().startListening(),
          );
        },
      );
}
