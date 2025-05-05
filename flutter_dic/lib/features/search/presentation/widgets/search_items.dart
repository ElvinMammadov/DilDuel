part of search;

class SearchItems extends StatelessWidget {
  const SearchItems({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
      builder: (BuildContext context, SearchState state) {
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
                    horizontal: 8,
                  ),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(word.key),
                      subtitle: Text(word.value),
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