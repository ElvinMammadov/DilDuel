part of quiz;

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) =>  DefaultTabController(
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
                    text: 'quiz.title'.tr(),
                    height: 35,
                  ),
                  Tab(
                    text: 'quiz.results.title'.tr(),
                    height: 35,
                  ),
                ],
              ),
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
