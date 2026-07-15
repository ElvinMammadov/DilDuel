part of search;

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
        builder: (BuildContext context, SearchState state) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final AppState appState = context.watch<AppCubit>().state;
          final Color primary = isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
          final Color primaryTint = isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
          final Color textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
          final Color textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
          final Color surface = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
          final Color border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

          if (state is SearchLoading) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (state is SearchLoaded) {
            if (state.words.isEmpty) {
              return _EmptySearchState(
                primary: primary,
                primaryTint: primaryTint,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              );
            }
            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: state.words.length,
                itemBuilder: (BuildContext context, int index) {
                  final Word word = state.words[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => showSearchBottomSheet(
                        context,
                        word,
                        appState.dictionaryType == DictionaryType.azDe ? 'az-AZ' : 'de-DE',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: surface,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(word.key, style: AppTheme.wordSource(textPrimary)),
                                  const SizedBox(height: 3),
                                  Text(word.value, style: AppTheme.bodyMedium(textSecondary)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: textSecondary.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is SearchError) {
            return _ErrorSearchState(
              primary: primary,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            );
          }

          return _EmptySearchState(
            primary: primary,
            primaryTint: primaryTint,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          );
        },
      );
}

class _EmptySearchState extends StatelessWidget {
  final Color primary;
  final Color primaryTint;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptySearchState({
    required this.primary,
    required this.primaryTint,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: primaryTint, shape: BoxShape.circle),
                  child: Icon(Icons.search, size: 26, color: primary),
                ),
                const SizedBox(height: 14),
                Text('search.empty.title'.tr(), style: AppTheme.titleMedium(textPrimary)),
                const SizedBox(height: 6),
                Text(
                  'search.empty.description'.tr(),
                  style: AppTheme.bodyMedium(textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}

class _ErrorSearchState extends StatelessWidget {
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;

  const _ErrorSearchState({
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppTheme.errorTint, shape: BoxShape.circle),
                  child: const Icon(Icons.error_outline, size: 26, color: AppTheme.errorColor),
                ),
                const SizedBox(height: 14),
                Text('search.error.title'.tr(), style: AppTheme.titleMedium(textPrimary)),
                const SizedBox(height: 6),
                Text('search.error.description'.tr(), style: AppTheme.bodyMedium(textSecondary), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}
