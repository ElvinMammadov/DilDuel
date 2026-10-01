part of quiz;

enum _QuizSection {
  quiz(Icons.quiz_outlined),
  listening(Icons.headphones_outlined),
  results(Icons.bar_chart_rounded);

  const _QuizSection(this.icon);

  final IconData icon;

  String get label => switch (this) {
        quiz => 'quiz.title'.tr(),
        listening => 'listening.title'.tr(),
        results => 'quiz.results.title'.tr(),
      };

  Color color(AppColors colors) => switch (this) {
        quiz => colors.quizCard,
        listening => colors.listeningCard,
        results => colors.resultsCard,
      };

  Widget get content => switch (this) {
        quiz => const QuizContent(),
        listening => const ListeningScreen(),
        results => const ResultsTab(),
      };
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  _QuizSection? _selected;
  late Future<Map<_QuizSection, int>> _counts = _loadCounts();

  Future<Map<_QuizSection, int>> _loadCounts() async {
    try {
      final Map<String, dynamic> quiz =
          await GetIt.I<QuizResultRepository>().getQuizStatistics();
      final Map<String, dynamic> listening =
          await GetIt.I<ListeningResultRepository>().getListeningStatistics();
      final int quizCount = quiz['totalQuizzes'] as int;
      final int listeningCount = listening['totalSessions'] as int;
      return <_QuizSection, int>{
        _QuizSection.quiz: quizCount,
        _QuizSection.listening: listeningCount,
        _QuizSection.results: quizCount + listeningCount,
      };
    } catch (_) {
      return const <_QuizSection, int>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final _QuizSection? selected = _selected;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous is AuthAuthenticated && current is AuthUnauthenticated,
      listener: (BuildContext context, AuthState state) =>
          context.read<QuizBloc>().cancelQuiz(),
      child: selected == null
          ? _QuizSectionCards(
              counts: _counts,
              onSelected: (_QuizSection section) =>
                  setState(() => _selected = section),
            )
          : Column(
              children: <Widget>[
                AppBackBar(
                  label: selected.label,
                  onBack: () => setState(() {
                    _selected = null;
                    _counts = _loadCounts();
                  }),
                ),
                Expanded(child: selected.content),
              ],
            ),
    );
  }
}

class _QuizSectionCards extends StatelessWidget {
  const _QuizSectionCards({required this.counts, required this.onSelected});

  final Future<Map<_QuizSection, int>> counts;
  final ValueChanged<_QuizSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    return FutureBuilder<Map<_QuizSection, int>>(
      future: counts,
      builder: (
        BuildContext context,
        AsyncSnapshot<Map<_QuizSection, int>> snapshot,
      ) =>
          AppFilledCardList(
        children: <Widget>[
          for (final _QuizSection section in _QuizSection.values)
            AppIconFilledCard(
              color: section.color(colors),
              icon: section.icon,
              label: section.label,
              count: snapshot.data?[section],
              onTap: () => onSelected(section),
            ),
        ],
      ),
    );
  }
}
