part of quiz;

class QuizRestartDialog extends StatelessWidget {
  final VoidCallback onRestart;

  const QuizRestartDialog({
    super.key,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) => AppDialog(
        icon: Icons.refresh_rounded,
        isDestructive: true,
        title: 'quiz.restart'.tr(),
        message: 'quiz.confirm_restart'.tr(),
        primary: AppDialogAction(
          label: 'common.cancel'.tr(),
          onPressed: () => Navigator.pop(context),
        ),
        secondary: AppDialogAction(
          label: 'quiz.restart'.tr(),
          isDestructive: true,
          onPressed: () {
            onRestart();
            Navigator.pop(context);
          },
        ),
      );
}
