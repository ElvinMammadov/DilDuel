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
              icon: Icons.search,
              color: colors.primary,
              tintColor: colors.primaryTint,
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
            color: colors.error,
            tintColor: colors.errorTint,
            title: 'search.error.title'.tr(),
            description: 'search.error.description'.tr(),
          );
        }

        // SearchInitial
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
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
          ),
          child: Padding(
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
        ),
      ),
    );
  }
}
