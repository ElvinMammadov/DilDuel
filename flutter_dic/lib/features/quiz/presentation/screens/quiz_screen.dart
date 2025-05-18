part of quiz;

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) => const DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Material(
              elevation: 0.5,
              child: TabBar(
                labelColor: AppTheme.mainColor,
                unselectedLabelColor: AppTheme.textSecondaryLight,
                dividerColor: Colors.transparent,
                tabs: <Widget>[
                  Tab(
                    text: 'Quiz',
                    height: 35,
                  ),
                  Tab(
                    text: 'Results',
                    height: 35,
                  ),
                ],
              ),
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
