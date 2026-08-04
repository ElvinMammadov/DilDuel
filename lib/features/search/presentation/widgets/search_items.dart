part of search;

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
        builder: (BuildContext context, SearchState state) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final AppState appState = context.watch<AppCubit>().state;
          final Color primary =
              isDark ? AppTheme.mainColorDark : AppTheme.mainColor;
          final Color primaryTint =
              isDark ? AppTheme.primaryTintDark : AppTheme.primaryTint;
          final Color textPrimary =
              isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
          final Color textSecondary =
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
          final Color surface =
              isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
          final Color border =
              isDark ? AppTheme.borderDark : AppTheme.borderLight;

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
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.padding20,
                      Dimensions.padding4,
                      Dimensions.padding20,
                      Dimensions.padding20,
                    ),
                itemCount: state.words.length,
                itemBuilder: (BuildContext context, int index) {
                  final Word word = state.words[index];
                  return _WordCard(
                    word: word,
                    surface: surface,
                    border: border,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () => showSearchBottomSheet(
                      context,
                      word,
                      appState.dictionaryType == DictionaryType.azDe
                          ? 'az-AZ'
                          : 'de-DE',
                      onBookmarkToggled: () =>
                          context.read<BookmarksBloc>().loadBookmarks(),
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

class _WordCard extends StatelessWidget {
  final Word word;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _WordCard({
    required this.word,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  /// Parses `word.value` into individual stripped translation strings.
  List<String> _translations() => TranslationChips.parse(word.value);

  @override
  Widget build(BuildContext context) {
    final bool isAzDe = word.dicType == 'AzDe';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16,
            vertical: Dimensions.padding14,
          ),
          decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border),
            borderRadius:
                BorderRadius.circular(Dimensions.borderRadiusLarge),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ── Word title ─────────────────────────────
                    Text(
                      word.key,
                      style: AppTextStyles.wordSource(textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Dimensions.itemHeight6),
                    // ── Translation ────────────────────────────
                    if (isAzDe)
                      TranslationChips(
                        translations: _translations(),
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        border: border,
                      )
                    else
                      Text(
                        word.value,
                        style: AppTextStyles.bodyMedium(textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.itemWidth8),
              Icon(
                Icons.chevron_right,
                size: Dimensions.itemWidth18,
                color: textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: Dimensions.itemWidth64,
                  height: Dimensions.itemHeight64,
                  decoration:
                      BoxDecoration(color: primaryTint, shape: BoxShape.circle),
                  child: Icon(Icons.search,
                      size: Dimensions.itemWidth26, color: primary),
                ),
                const SizedBox(height: Dimensions.itemHeight14),
                Text('search.empty.title'.tr(),
                    style: AppTextStyles.titleMedium(textPrimary)),
                const SizedBox(height: Dimensions.itemHeight6),
                Text(
                  'search.empty.description'.tr(),
                  style: AppTextStyles.bodyMedium(textSecondary),
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
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.padding24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: Dimensions.itemWidth64,
                  height: Dimensions.itemHeight64,
                  decoration: const BoxDecoration(
                      color: AppTheme.errorTint, shape: BoxShape.circle),
                  child: const Icon(Icons.error_outline,
                      size: Dimensions.itemWidth26,
                      color: AppTheme.errorColor),
                ),
                const SizedBox(height: Dimensions.itemHeight14),
                Text('search.error.title'.tr(),
                    style: AppTextStyles.titleMedium(textPrimary)),
                const SizedBox(height: Dimensions.itemHeight6),
                Text('search.error.description'.tr(),
                    style: AppTextStyles.bodyMedium(textSecondary),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}
