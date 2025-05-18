part of quiz;

class QuizInitialView extends StatelessWidget {
  final VoidCallback onStart;

  const QuizInitialView({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: AppElevatedButton(
          text: 'Start Quiz',
          onPressed: onStart,
        ),
      );
} 