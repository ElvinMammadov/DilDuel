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
              return EmptyStateView(
                icon: Icons.search,
                color: primary,
                tintColor: primaryTint,
                title: 'search.empty.title'.tr(),
                description: 'search.empty.description'.tr(),
              );
            }
                return ListView.builder(
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
                  );
          }

          if (state is SearchError) {
            return EmptyStateView(
              icon: Icons.error_outline,
              color: AppTheme.errorColor,
              tintColor: AppTheme.errorTint,
              title: 'search.error.title'.tr(),
              description: 'search.error.description'.tr(),
            );
          }

          return EmptyStateView(
            icon: Icons.search,
            color: primary,
            tintColor: primaryTint,
            title: 'search.empty.title'.tr(),
            description: 'search.empty.description'.tr(),
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
