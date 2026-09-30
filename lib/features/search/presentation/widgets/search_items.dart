part of search;

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final AppState appState = context.watch<AppCubit>().state;

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (BuildContext context, SearchState state) {
        if (state is SearchLoading) {
          return Center(
            child: CircularProgressIndicator(color: colors.primary),
          );
        }

        if (state is SearchLoaded) {
          if (state.words.isEmpty) {
            return EmptyStateView(
              icon: Icons.search_off_rounded,
              color: colors.warning,
              tintColor: colors.warningTint,
              title: 'search.not_found.title'.tr(args: <String>[state.query]),
              description: 'search.not_found.description'.tr(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.padding16,
              Dimensions.padding4,
              Dimensions.padding16,
              Dimensions.padding20,
            ),
            itemCount: state.words.length,
            itemBuilder: (BuildContext context, int index) {
              final Word word = state.words[index];
              return _WordCard(
                word: word,
                onTap: () {
                  context
                      .read<SearchBloc>()
                      .saveSearch(state.query, appState.dictionaryType.name);
                  showSearchBottomSheet(
                    context,
                    word,
                    appState.dictionaryType == DictionaryType.azDe
                        ? 'az-AZ'
                        : 'de-DE',
                    onBookmarkToggled: () =>
                        context.read<BookmarksBloc>().loadBookmarks(),
                  );
                },
              );
            },
          );
        }

        if (state is SearchError) {
          return EmptyStateView(
            icon: Icons.error_outline,
            color: colors.error,
            tintColor: colors.errorTint,
            title: 'search.error.title'.tr(),
            description: 'search.error.description'.tr(),
          );
        }

        // SearchInitial
        if (state is SearchInitial && state.recentQueries.isNotEmpty) {
          return _RecentSearchList(queries: state.recentQueries);
        }

        return EmptyStateView(
          icon: Icons.search,
          color: colors.primary,
          tintColor: colors.primaryTint,
          title: 'search.empty.title'.tr(),
          description: 'search.empty.description'.tr(),
        );
      },
    );
  }
}

class _RecentSearchList extends StatelessWidget {
  final List<String> queries;

  const _RecentSearchList({required this.queries});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.padding16,
        Dimensions.padding8,
        Dimensions.padding16,
        Dimensions.padding20,
      ),
      itemCount: queries.length + 1,
      separatorBuilder: (_, __) =>
          const SizedBox(height: Dimensions.itemHeight6),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.padding8),
            child: Text(
              'search.recent_searches'.tr(),
              style: AppTextStyles.labelMedium(colors.textSecondary),
            ),
          );
        }
        final String query = queries[index - 1];
        return AppCard(
          onTap: () => context.read<SearchBloc>().recentTapped(query),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding16,
            vertical: Dimensions.padding14,
          ),
          child: Row(
                children: <Widget>[
                  Icon(
                    Icons.history_rounded,
                    size: Dimensions.itemWidth16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: Dimensions.itemWidth10),
                  Expanded(
                    child: Text(
                      query,
                      style: AppTextStyles.bodyLarge(colors.textPrimary),
                    ),
                  ),
                  Icon(
                    Icons.north_west_rounded,
                    size: Dimensions.itemWidth14,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                ],
              ),
        );
      },
    );
  }
}

class _WordCard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;

  const _WordCard({required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = AppColors.of(context);
    final bool isAzDe = word.dicType == 'AzDe';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.padding10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.padding16,
          vertical: Dimensions.padding14,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    word.key,
                    style: AppTextStyles.wordSource(colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.itemHeight6),
                  if (isAzDe)
                    TranslationChips(
                      translations: TranslationChips.parse(word.value),
                    )
                  else
                    Text(
                      word.value,
                      style: AppTextStyles.bodyMedium(colors.textSecondary),
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
              color: colors.textSecondary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
