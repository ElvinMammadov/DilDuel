part of quiz;

class QuizRestartDialog extends StatelessWidget {
  final VoidCallback onRestart;

  const QuizRestartDialog({
    super.key,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Restart Quiz?'),
        content: const Text(
          'Are you sure you want to restart?'
          ' Your current progress will be lost.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onRestart();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Restart'),
          ),
        ],
      );
} 