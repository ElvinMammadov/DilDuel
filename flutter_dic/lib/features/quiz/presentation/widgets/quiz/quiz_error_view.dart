part of quiz;

class QuizErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onTryAgain;

  const QuizErrorView({
    super.key,
    required this.message,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Error: $message',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.errorColor,
                  ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding16),
              child: AppElevatedButton(
                text: 'Try Again',
                onPressed: onTryAgain,
              ),
            ),
          ],
        ),
      );
} 