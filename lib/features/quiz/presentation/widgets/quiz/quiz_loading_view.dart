part of quiz;

class QuizLoadingView extends StatelessWidget {
  const QuizLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      );
}
