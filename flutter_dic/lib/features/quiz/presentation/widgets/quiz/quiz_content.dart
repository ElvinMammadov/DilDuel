part of quiz;

class QuizContent extends StatelessWidget {
  const QuizContent({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<QuizBloc, QuizState>(
        builder: (BuildContext context, QuizState state) {
          if (state is QuizLoading) {
            return const QuizLoadingView();
          }

          if (state is QuizError) {
            return QuizErrorView(
              message: state.message,
              onTryAgain: () => context.read<QuizBloc>().resetQuiz(),
            );
          }

          if (state is QuizInProgress) {
            return QuizInProgressView(state: state);
          }

          if (state is QuizComplete) {
            return QuizResultView(
              score: state.score,
              totalQuestions: state.totalQuestions,
              onTryAgain: () => context.read<QuizBloc>().resetQuiz(),
            );
          }

          // Initial state or unknown state
          return QuizInitialView(
            onStart: () => context.read<QuizBloc>().startQuiz(
                  context.read<AppCubit>().state.dictionaryType.name,
                ),
          );
        },
      );
}