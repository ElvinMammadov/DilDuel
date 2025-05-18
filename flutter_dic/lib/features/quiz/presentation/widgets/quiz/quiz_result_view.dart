part of quiz;

class QuizResultView extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onTryAgain;

  const QuizResultView({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (score / totalQuestions) * 100;
    final String emoji = _getEmojiForScore(percentage);

    return Center(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              emoji,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding20),
              child: Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding20),
              child: Column(
                children: <Widget>[
                  Text(
                    'Score: $score/$totalQuestions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimaryLight,
                        ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getColorForScore(percentage),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding20),
              child: Text(
                _getMessageForScore(percentage),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.padding40),
              child: AppElevatedButton(
                text: 'Try Again',
                onPressed: onTryAgain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForScore(double percentage) {
    if (percentage >= 90) return '🏆';
    if (percentage >= 70) return '🌟';
    if (percentage >= 50) return '👍';
    return '💪';
  }

  Color _getColorForScore(double percentage) {
    if (percentage >= 90) return AppTheme.successColor;
    if (percentage >= 70) return AppTheme.successColor.withAlpha(204);
    if (percentage >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getMessageForScore(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! You\'re a vocabulary master!';
    }
    if (percentage >= 70) {
      return 'Great job! Keep up the good work!';
    }
    if (percentage >= 50) {
      return 'Good effort! Practice makes perfect!';
    }
    return 'Keep practicing! You\'ll improve!';
  }
} 