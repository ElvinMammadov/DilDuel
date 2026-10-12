part of listening;

class ListeningInProgressView extends StatelessWidget {
  final ListeningInProgress state;

  const ListeningInProgressView({super.key, required this.state});

  void _showCancelDialog(BuildContext context) {
    final ListeningCubit cubit = context.read<ListeningCubit>();
    AppDialog.show<void>(
      context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: Icons.close_rounded,
        isDestructive: true,
        title: 'quiz.confirm_cancel'.tr(),
        primary: AppDialogAction(
          label: 'quiz.no'.tr(),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        secondary: AppDialogAction(
          label: 'quiz.yes'.tr(),
          isDestructive: true,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            cubit.cancel();
          },
        ),
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    final ListeningCubit cubit = context.read<ListeningCubit>();
    AppDialog.show<void>(
      context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: Icons.refresh_rounded,
        isDestructive: true,
        title: 'quiz.confirm_restart'.tr(),
        primary: AppDialogAction(
          label: 'quiz.no'.tr(),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        secondary: AppDialogAction(
          label: 'quiz.yes'.tr(),
          isDestructive: true,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            cubit.startListening();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.padding16,
            Dimensions.padding4,
            Dimensions.padding16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: AppCard(
              padding: const EdgeInsets.all(Dimensions.padding14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'quiz.question'.tr(args: <String>[
                          '${state.currentIndex + 1}',
                          '${state.questions.length}',
                        ]),
                        style: AppTextStyles.titleMedium(colors.textPrimary),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'quiz.score'
                                .tr(args: <String>['${state.score}']),
                            style:
                                AppTextStyles.titleMedium(colors.primary),
                          ),
                          const SizedBox(width: Dimensions.itemWidth14),
                          GestureDetector(
                            onTap: () => _showRestartDialog(context),
                            child: Icon(Icons.refresh,
                                size: Dimensions.itemWidth18,
                                color: colors.primary),
                          ),
                          const SizedBox(width: Dimensions.itemWidth14),
                          GestureDetector(
                            onTap: () => _showCancelDialog(context),
                            child: Icon(Icons.close,
                                size: Dimensions.itemWidth18,
                                color: colors.error),
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
                      value: (state.currentIndex + 1) /
                          state.questions.length,
                      minHeight: Dimensions.itemHeight6,
                      backgroundColor: colors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding16),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: ListeningQuestionCard(
              key: ValueKey<int>(state.currentIndex),
              question: state.currentQuestion,
              onAnswer: (String answer) =>
                  context.read<ListeningCubit>().answer(answer),
            ),
          ),
        ),
      ],
    );
  }
}
