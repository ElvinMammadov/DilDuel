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
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final Color error = isDark ? AppTheme.errorColorDark : AppTheme.errorColor;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.padding16,
              Dimensions.padding4,
              Dimensions.padding16,
              0),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(Dimensions.padding14),
              decoration: BoxDecoration(
                color: surface,
                border: Border.all(color: border),
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'quiz.question'.tr(args: <String>[
                          '${state.currentIndex + 1}',
                          '${state.words.length}',
                        ]),
                        style: AppTextStyles.titleMedium(textPrimary),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'quiz.score'.tr(args: <String>['${state.score}']),
                            style: AppTextStyles.titleMedium(primary),
                          ),
                          const SizedBox(width: Dimensions.itemWidth14),
                          GestureDetector(
                            onTap: () => _showRestartDialog(context),
                            child: Icon(Icons.refresh,
                                size: Dimensions.itemWidth18, color: primary),
                          ),
                          const SizedBox(width: Dimensions.itemWidth14),
                          GestureDetector(
                            onTap: () => _showCancelDialog(context),
                            child: Icon(Icons.close,
                                size: Dimensions.itemWidth18, color: error),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.itemHeight10),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(Dimensions.borderRadiusPill),
                    child: LinearProgressIndicator(
                      value: (state.currentIndex + 1) / state.words.length,
                      minHeight: Dimensions.itemHeight6,
                      backgroundColor: border,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding16),
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
}
