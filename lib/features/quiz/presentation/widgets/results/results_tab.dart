part of quiz;

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
                  child: ListTile(
                    title: Text('quiz.results.statistics'.tr()),
                    subtitle: Text(
                      'quiz.results.stats_details'.tr(args: <String>[
                        '${stats['totalQuizzes']}',
                        '${stats['averageScore']}'
                      ]),
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
                  return Center(
                    child: Text(
                      'quiz.results.empty'.tr(),
                      textAlign: TextAlign.center,
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
                    final String percentage =
                        ((result.score / result.totalQuestions) * 100)
                            .toStringAsFixed(1);

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text('quiz.results.quiz_number'
                            .tr(args: <String>['${index + 1}'])),
                        subtitle: Text(
                          'quiz.results.score_details'.tr(args: <String>[
                            '${result.score}',
                            '${result.totalQuestions}',
                            percentage
                          ]),
                        ),
                        trailing: Text(date),
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
