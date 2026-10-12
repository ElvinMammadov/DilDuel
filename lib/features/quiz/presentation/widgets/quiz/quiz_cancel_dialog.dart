part of quiz;

class QuizCancelDialog extends StatelessWidget {
  final VoidCallback onCancel;

  const QuizCancelDialog({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => AppDialog(
        icon: Icons.close_rounded,
        isDestructive: true,
        title: 'quiz.cancel'.tr(),
        message: 'quiz.confirm_cancel'.tr(),
        primary: AppDialogAction(
          label: 'common.no'.tr(),
          onPressed: () => Navigator.pop(context),
        ),
        secondary: AppDialogAction(
          label: 'common.yes'.tr(),
          isDestructive: true,
          onPressed: () {
            onCancel();
            Navigator.pop(context);
          },
        ),
      );
}
