part of quiz;

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) => const DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              labelColor: AppTheme.mainColor,
              unselectedLabelColor: AppTheme.textSecondaryLight,
              tabs: <Widget>[
                Tab(text: 'Quiz'),
                Tab(text: 'Results'),
              ],
            ),
            Expanded(
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