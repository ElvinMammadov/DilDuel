part of quiz;

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding12,
          vertical: Dimensions.padding12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryTint,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.mainColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

Color _scoreColor(double pct) {
  if (pct >= 70) return AppTheme.successColor;
  if (pct >= 40) return AppTheme.warningColor;
  return AppTheme.errorColor;
}

Color _scoreBg(double pct) {
  if (pct >= 70) return AppTheme.successTint;
  if (pct >= 40) return const Color(0xFFFFF3E0);
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
  Widget build(BuildContext context) => RefreshIndicator(
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
                    <String, dynamic>{'totalQuizzes': 0, 'averageScore': '0.0'};

                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.padding16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'quiz.results.statistics'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Dimensions.padding12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _MetricChip(
                                label: 'quiz.results.total_quizzes_label'.tr(),
                                value: '${stats['totalQuizzes']}',
                              ),
                            ),
                            const SizedBox(width: Dimensions.padding8),
                            Expanded(
                              child: _MetricChip(
                                label: 'quiz.results.average_score_label'.tr(),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                    padding: const EdgeInsets.only(top: Dimensions.padding20),
                    child: Center(
                      child: Text(
                        'quiz.results.empty'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Dimensions.itemHeight8),
                  itemBuilder: (BuildContext context, int index) {
                    final QuizResult result = results[index];
                    final String date =
                        DateFormat('MMM d, y HH:mm').format(result.dateTime);
                    final double percentageValue =
                        (result.score / result.totalQuestions) * 100;
                    final String percentage =
                        percentageValue.toStringAsFixed(1);

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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'quiz.results.score_details'
                                        .tr(args: <String>[
                                      '${result.score}',
                                      '${result.totalQuestions}',
                                      percentage,
                                    ]),
                                    style: const TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontSize: 11,
                                    ),
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
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                              ),
                              child: Text(
                                '$percentage%',
                                style: TextStyle(
                                  color: _scoreColor(percentageValue),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
}
