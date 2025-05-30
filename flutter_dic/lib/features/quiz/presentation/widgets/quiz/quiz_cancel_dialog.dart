part of quiz;

class QuizCancelDialog extends StatelessWidget {
  final VoidCallback onCancel;

  const QuizCancelDialog({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('quiz.cancel'.tr()),
        content: Text('quiz.confirm_cancel'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.no'.tr()),
          ),
          TextButton(
            onPressed: () {
              onCancel();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text('common.yes'.tr()),
          ),
        ],
      );
} 