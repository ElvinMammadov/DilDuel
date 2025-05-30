part of quiz;

class QuizResultView extends StatelessWidget {
  final QuizComplete state;
  final VoidCallback onTryAgain;

  const QuizResultView({
    super.key,
    required this.state,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final int correctAnswers = state.score;
    final int totalQuestions = state.totalQuestions;
    final double percentage = (correctAnswers / totalQuestions) * 100;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _getEmojiForScore(percentage),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: Dimensions.padding16),
          Text(
            'quiz.score'.tr(args: <String>['$correctAnswers/$totalQuestions']),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _getColorForScore(percentage),
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
              text: 'quiz.try_again'.tr(),
              onPressed: onTryAgain,
            ),
          ),
        ],
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
      return 'quiz.results.excellent'.tr();
    }
    if (percentage >= 70) {
      return 'quiz.results.great'.tr();
    }
    if (percentage >= 50) {
      return 'quiz.results.good'.tr();
    }
    return 'quiz.results.keep_trying'.tr();
  }
} 