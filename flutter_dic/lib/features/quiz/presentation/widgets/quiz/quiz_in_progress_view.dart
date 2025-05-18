part of quiz;

class QuizInProgressView extends StatelessWidget {
  final QuizInProgress state;

  const QuizInProgressView({
    super.key,
    required this.state,
  });

  void _showRestartDialog(BuildContext context) {
    final QuizBloc quizBloc = context.read<QuizBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => QuizRestartDialog(
        onRestart: () {
          quizBloc.resetQuiz();
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final QuizBloc quizBloc = context.read<QuizBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => QuizCancelDialog(
        onCancel: () {
          quizBloc.cancelQuiz();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimensions.padding16),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: Dimensions.padding4),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.padding8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Question ${state.currentIndex + 1}/${state.words.length}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Score: ${state.score}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.mainColor,
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.restart_alt),
                                  color: AppTheme.mainColor,
                                  tooltip: 'Restart Quiz',
                                  onPressed: () => _showRestartDialog(context),
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.padding16),
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: AppTheme.errorColor,
                                  tooltip: 'Cancel Quiz',
                                  onPressed: () => _showCancelDialog(context),
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.padding8),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.itemHeight8),
                        LinearProgressIndicator(
                          value: (state.currentIndex + 1) / state.words.length,
                          backgroundColor: AppTheme.accentColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.mainColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimensions.padding16),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: QuizQuestion(
                word: state.words[state.currentIndex],
                onAnswer: (String answer) =>
                    context.read<QuizBloc>().answerQuestion(answer),
                lastAnswerCorrect: state.lastAnswerCorrect,
              ),
            ),
          ),
        ],
      );
}
