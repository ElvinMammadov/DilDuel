part of search;

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
        builder: (BuildContext context, SearchState state) {
          final ThemeData theme = Theme.of(context);
          final AppState appState = context.watch<AppCubit>().state;
          if (state is SearchLoading) {
            return const CircularProgressIndicator();
          } else if (state is SearchLoaded) {
            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.words.length,
                itemBuilder: (BuildContext context, int index) {
                  final Word word = state.words[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.padding16,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showSearchBottomSheet(
                          context,
                          word,
                          appState.dictionaryType == DictionaryType.azDe
                              ? 'az-AZ'
                              : 'de-DE',
                        );
                      },
                      child: Card(
                        elevation: Dimensions.itemHeight1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.itemHeight8),
                        ),
                        child: ListTile(
                          title: Text(
                            word.key,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(word.value),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is SearchError) {
            return const Text('Error fetching results');
          }
          return const SizedBox.shrink();
        },
      );
}
