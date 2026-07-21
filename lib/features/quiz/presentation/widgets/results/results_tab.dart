part of quiz;

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
    final Color primaryTint =
        isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding12,
        vertical: Dimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: primaryTint,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: AppTextStyles.scoreDisplay(primary)),
          const SizedBox(height: Dimensions.itemHeight2),
          Text(label, style: AppTextStyles.caption(textSecondary)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final QuizResult result;
  final int index;

  const _ResultCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    final String date = DateFormat('MMM d, y HH:mm').format(result.dateTime);
    final double percentageValue =
        (result.score / result.totalQuestions) * 100;
    final String percentage = percentageValue.toStringAsFixed(1);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'quiz.results.quiz_number'
                        .tr(args: <String>['${index + 1}']),
                    style: AppTextStyles.labelLarge(textPrimary),
                  ),
                  const SizedBox(height: Dimensions.itemHeight2),
                  Text(
                    'quiz.results.score_details'.tr(args: <String>[
                      '${result.score}',
                      '${result.totalQuestions}',
                      percentage,
                    ]),
                    style: AppTextStyles.bodySmall(textSecondary),
                  ),
                  const SizedBox(height: Dimensions.itemHeight4),
                  Text(
                    date,
                    style: AppTextStyles.labelSmall(textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.padding12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding12,
                vertical: Dimensions.padding8,
              ),
              decoration: BoxDecoration(
                color: _scoreBg(percentageValue),
                borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              ),
              child: Text(
                '$percentage%',
                style: AppTextStyles.labelLarge(_scoreColor(percentageValue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _scoreColor(double pct) {
  if (pct >= 70) return AppTheme.successColor;
  if (pct >= 40) return AppTheme.warningColor;
  return AppTheme.errorColor;
}

Color _scoreBg(double pct) {
  if (pct >= 70) return AppTheme.successTint;
  if (pct >= 40) return AppTheme.warningTint;
  return AppTheme.errorTint;
}

class ResultsTab extends StatefulWidget {
  const ResultsTab({super.key});

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  late Future<Map<String, dynamic>> _statisticsFuture;
  late Future<List<QuizResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _statisticsFuture = DBHelper.getQuizStatistics();
    _resultsFuture = DBHelper.getQuizResults();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final Color textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadData();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(Dimensions.padding16),
        children: <Widget>[
          FutureBuilder<Map<String, dynamic>>(
            future: _statisticsFuture,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text('quiz.results.loading'.tr()),
                  ),
                );
              }

              final Map<String, dynamic> stats = snapshot.data ??
                  <String, dynamic>{
                    'totalQuizzes': 0,
                    'averageScore': '0.0',
                  };

              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.padding16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'quiz.results.statistics'.tr(),
                        style: AppTextStyles.titleSmall(textPrimary),
                      ),
                      const SizedBox(height: Dimensions.padding12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _MetricChip(
                              label:
                                  'quiz.results.total_quizzes_label'.tr(),
                              value: '${stats['totalQuizzes']}',
                            ),
                          ),
                          const SizedBox(width: Dimensions.padding8),
                          Expanded(
                            child: _MetricChip(
                              label:
                                  'quiz.results.average_score_label'.tr(),
                              value: '${stats['averageScore']}%',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.padding20,
              bottom: Dimensions.padding12,
            ),
            child: Text(
              'quiz.results.history'.tr(),
              style: AppTextStyles.titleXLarge(textPrimary),
            ),
          ),
          FutureBuilder<List<QuizResult>>(
            future: _resultsFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<QuizResult>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<QuizResult> results =
                  snapshot.data ?? <QuizResult>[];

              if (results.isEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.padding20),
                  child: Center(
                    child: Text(
                      'quiz.results.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(textSecondary),
                    ),
                  ),
                );
              }

              return Column(
                children: List<Widget>.generate(
                  results.length,
                  (int index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < results.length - 1
                          ? Dimensions.itemHeight8
                          : 0,
                    ),
                    child: _ResultCard(
                      result: results[index],
                      index: index,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
