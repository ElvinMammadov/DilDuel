part of quiz;

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color primary = colors.primary;
    final Color primaryTint = colors.primaryTint;
    final Color textSecondary = colors.textSecondary;

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
    final AppColors colors = AppColors.of(context);
    final Color textPrimary = colors.textPrimary;
    final Color textSecondary = colors.textSecondary;

    final String date = DateFormat('MMM d, y HH:mm').format(result.dateTime);
    final double percentageValue = (result.score / result.totalQuestions) * 100;
    final String percentage = percentageValue.toStringAsFixed(1);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: result.answers.isEmpty
            ? null
            : () => _showAnswersSheet(context),
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
                  color: _scoreBg(percentageValue, colors),
                  borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.labelLarge(
                    _scoreColor(percentageValue, colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.borderRadiusSheet),
        ),
      ),
      builder: (BuildContext context) => _AnswersBottomSheet(
        result: result,
        index: index,
      ),
    );
  }
}

class _AnswersBottomSheet extends StatelessWidget {
  final QuizResult result;
  final int index;

  const _AnswersBottomSheet({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final double pct = (result.score / result.totalQuestions) * 100;
    final int wrong = result.totalQuestions - result.score;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController controller) => Column(
        children: <Widget>[
          // ── Handle ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.padding12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.25),
                borderRadius:
                    BorderRadius.circular(Dimensions.borderRadiusPill),
              ),
              child: const SizedBox(width: 40, height: 4),
            ),
          ),
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.padding20,
              0,
              Dimensions.padding20,
              Dimensions.padding16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'quiz.results.quiz_number'
                          .tr(args: <String>['${index + 1}']),
                      style: AppTextStyles.titleMedium(colors.textPrimary),
                    ),
                    Text(
                      DateFormat('d MMM · HH:mm').format(result.dateTime),
                      style: AppTextStyles.caption(colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.padding12),
                Row(
                  children: <Widget>[
                    _SheetStatChip(
                      label: '${result.score}',
                      suffix: ' ${'quiz.correct'.tr()}',
                      color: colors.success,
                      bg: colors.successTint,
                    ),
                    const SizedBox(width: Dimensions.padding8),
                    _SheetStatChip(
                      label: '$wrong',
                      suffix: ' ${'quiz.wrong'.tr()}',
                      color: colors.error,
                      bg: colors.errorTint,
                    ),
                    const Spacer(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: _scoreBg(pct, colors),
                        borderRadius:
                            BorderRadius.circular(Dimensions.borderRadiusPill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.padding16,
                          vertical: Dimensions.padding6,
                        ),
                        child: Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: AppTextStyles.labelLarge(
                              _scoreColor(pct, colors)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Answer list ─────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(
                Dimensions.padding16,
                Dimensions.padding12,
                Dimensions.padding16,
                Dimensions.padding24,
              ),
              itemCount: result.answers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Dimensions.padding8),
              itemBuilder: (BuildContext context, int i) => _AnswerCard(
                answer: result.answers[i],
                number: i + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetStatChip extends StatelessWidget {
  const _SheetStatChip({
    required this.label,
    required this.suffix,
    required this.color,
    required this.bg,
  });

  final String label;
  final String suffix;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusPill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding12,
            vertical: Dimensions.padding6,
          ),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: label,
                  style: AppTextStyles.labelMedium(color),
                ),
                TextSpan(
                  text: suffix,
                  style: AppTextStyles.caption(color),
                ),
              ],
            ),
          ),
        ),
      );
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer, required this.number});

  final AnswerRecord answer;
  final int number;

  String _clean(String raw) {
    final String first = raw.split('\n').first.trim();
    return first.replaceFirst(RegExp(r'^\d+\.\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color accent = answer.isCorrect ? colors.success : colors.error;
    final Color bg = answer.isCorrect ? colors.successTint : colors.errorTint;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Colored left accent bar
            SizedBox(
              width: Dimensions.itemHeight4,
              child: ColoredBox(color: accent),
            ),
            // Card body
            Expanded(
              child: ColoredBox(
                color: bg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.padding12,
                    vertical: Dimensions.padding10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Number badge
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(Dimensions.padding6),
                        ),
                        child: SizedBox(
                          width: Dimensions.itemWidth28,
                          height: Dimensions.itemHeight28,
                          child: Center(
                            child: Text(
                              '$number',
                              style: AppTextStyles.labelSmall(accent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.padding10),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _clean(answer.question),
                              style:
                                  AppTextStyles.labelLarge(colors.textPrimary),
                            ),
                            const SizedBox(height: Dimensions.itemHeight2),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: Dimensions.itemHeight12,
                                  color: colors.success,
                                ),
                                const SizedBox(width: Dimensions.padding4),
                                Flexible(
                                  child: Text(
                                    _clean(answer.correctAnswer),
                                    style: AppTextStyles.bodySmall(
                                        colors.success),
                                  ),
                                ),
                              ],
                            ),
                            if (!answer.isCorrect) ...<Widget>[
                              const SizedBox(height: Dimensions.itemHeight2),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.close_rounded,
                                    size: Dimensions.itemHeight12,
                                    color: colors.error,
                                  ),
                                  const SizedBox(width: Dimensions.padding4),
                                  Flexible(
                                    child: Text(
                                      _clean(answer.givenAnswer),
                                      style:
                                          AppTextStyles.bodySmall(colors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.padding8),
                      // Status icon
                      Icon(
                        answer.isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: Dimensions.itemHeight20,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _scoreColor(double pct, AppColors colors) {
  if (pct >= 70) return colors.success;
  if (pct >= 40) return colors.warning;
  return colors.error;
}

Color _scoreBg(double pct, AppColors colors) {
  if (pct >= 70) return colors.successTint;
  if (pct >= 40) return colors.warningTint;
  return colors.errorTint;
}

class ResultsTab extends StatefulWidget {
  const ResultsTab({super.key});

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  late Future<Map<String, dynamic>> _quizStatsFuture;
  late Future<List<QuizResult>> _quizResultsFuture;
  late Future<Map<String, dynamic>> _listeningStatsFuture;
  late Future<List<QuizResult>> _listeningResultsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final QuizResultRepository repo = GetIt.I<QuizResultRepository>();
    final ListeningResultRepository listeningRepo =
        GetIt.I<ListeningResultRepository>();
    _quizStatsFuture = repo.getQuizStatistics();
    _quizResultsFuture = repo.getQuizResults();
    _listeningStatsFuture = listeningRepo.getListeningStatistics();
    _listeningResultsFuture = listeningRepo.getListeningResults();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          (previous is AuthAuthenticated && current is AuthUnauthenticated) ||
          (previous is AuthUnauthenticated && current is AuthAuthenticated),
      listener: (BuildContext context, AuthState state) =>
          setState(_loadData),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSegmentedControl(
              labels: <String>[
                'quiz.title'.tr(),
                'listening.title'.tr(),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  RefreshIndicator(
                    onRefresh: () async => setState(_loadData),
                    child: _QuizResultsList(
                      statsFuture: _quizStatsFuture,
                      resultsFuture: _quizResultsFuture,
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () async => setState(_loadData),
                    child: _ListeningResultsList(
                      statsFuture: _listeningStatsFuture,
                      resultsFuture: _listeningResultsFuture,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

class _QuizResultsList extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final Future<List<QuizResult>> resultsFuture;

  const _QuizResultsList({
    required this.statsFuture,
    required this.resultsFuture,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color textPrimary = colors.textPrimary;
    final Color textSecondary = colors.textSecondary;

    return ListView(
      padding: const EdgeInsets.all(Dimensions.padding16),
      children: <Widget>[
        FutureBuilder<Map<String, dynamic>>(
          future: statsFuture,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(title: Text('quiz.results.loading'.tr())),
              );
            }
            final Map<String, dynamic> stats = snapshot.data ??
                <String, dynamic>{'totalQuizzes': 0, 'averageScore': '0.0'};
            return _StatsCard(
              title: 'quiz.results.translation_statistics'.tr(),
              totalLabel: 'quiz.results.total_quizzes_label'.tr(),
              totalValue: '${stats['totalQuizzes']}',
              avgLabel: 'quiz.results.average_score_label'.tr(),
              avgValue: '${stats['averageScore']}%',
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: Dimensions.padding20,
            bottom: Dimensions.padding12,
          ),
          child: Text(
            'quiz.results.translation_history'.tr(),
            style: AppTextStyles.titleXLarge(textPrimary),
          ),
        ),
        FutureBuilder<List<QuizResult>>(
          future: resultsFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<QuizResult>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<QuizResult> results = snapshot.data ?? <QuizResult>[];
            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: Dimensions.padding20),
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
                  child: _ResultCard(result: results[index], index: index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ListeningResultsList extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final Future<List<QuizResult>> resultsFuture;

  const _ListeningResultsList({
    required this.statsFuture,
    required this.resultsFuture,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final Color textPrimary = colors.textPrimary;
    final Color textSecondary = colors.textSecondary;

    return ListView(
      padding: const EdgeInsets.all(Dimensions.padding16),
      children: <Widget>[
        FutureBuilder<Map<String, dynamic>>(
          future: statsFuture,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(title: Text('quiz.results.loading'.tr())),
              );
            }
            final Map<String, dynamic> stats = snapshot.data ??
                <String, dynamic>{'totalSessions': 0, 'averageScore': '0.0'};
            return _StatsCard(
              title: 'listening.results.statistics'.tr(),
              totalLabel: 'listening.results.total_sessions_label'.tr(),
              totalValue: '${stats['totalSessions']}',
              avgLabel: 'quiz.results.average_score_label'.tr(),
              avgValue: '${stats['averageScore']}%',
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: Dimensions.padding20,
            bottom: Dimensions.padding12,
          ),
          child: Text(
            'listening.results.history'.tr(),
            style: AppTextStyles.titleXLarge(textPrimary),
          ),
        ),
        FutureBuilder<List<QuizResult>>(
          future: resultsFuture,
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
                    'listening.results.empty'.tr(),
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
                  child: _ResultCard(result: results[index], index: index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String totalLabel;
  final String totalValue;
  final String avgLabel;
  final String avgValue;

  const _StatsCard({
    required this.title,
    required this.totalLabel,
    required this.totalValue,
    required this.avgLabel,
    required this.avgValue,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title,
                style: AppTextStyles.titleSmall(colors.textPrimary)),
            const SizedBox(height: Dimensions.padding12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricChip(label: totalLabel, value: totalValue),
                ),
                const SizedBox(width: Dimensions.padding8),
                Expanded(
                  child: _MetricChip(label: avgLabel, value: avgValue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
