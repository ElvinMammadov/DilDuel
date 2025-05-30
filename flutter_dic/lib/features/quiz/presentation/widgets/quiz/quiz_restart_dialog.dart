part of quiz;

class QuizRestartDialog extends StatelessWidget {
  final VoidCallback onRestart;

  const QuizRestartDialog({
    super.key,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('quiz.restart'.tr()),
        content: Text('quiz.confirm_restart'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              onRestart();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text('quiz.restart'.tr()),
          ),
        ],
      );
} 