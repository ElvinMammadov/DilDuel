part of quiz;

class QuizCancelDialog extends StatelessWidget {
  final VoidCallback onCancel;

  const QuizCancelDialog({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Cancel Quiz?'),
        content: const Text(
          'Are you sure you want to cancel the quiz?'
          ' Your progress will be lost.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              onCancel();
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes'),
          ),
        ],
      );
} 