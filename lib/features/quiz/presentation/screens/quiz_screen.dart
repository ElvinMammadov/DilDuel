part of quiz;

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            labelColor: primary,
            unselectedLabelColor: textSecondary,
            indicatorColor: primary,
            indicatorWeight: 2.5,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyles.titleSmall(primary),
            unselectedLabelStyle: AppTextStyles.titleSmall(textSecondary),
            tabs: <Widget>[
              Tab(text: 'quiz.title'.tr(), height: Dimensions.itemHeight44),
              Tab(
                  text: 'quiz.results.title'.tr(),
                  height: Dimensions.itemHeight44),
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
}
