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
          text: 'quiz.start'.tr(),
          onPressed: onStart,
        ),
      );
}
