part of quiz;

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSegmentedControl(
              labels: <String>[
                'quiz.title'.tr(),
                'quiz.results.title'.tr(),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: <Widget>[
                  QuizContent(),
                  ResultsTab(),
                ],
              ),
            ),
          ],
        ),
      );
}

