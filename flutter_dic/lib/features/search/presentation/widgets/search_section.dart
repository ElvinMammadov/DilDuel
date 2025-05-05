part of search;

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final SearchController _controller = SearchController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final bool isTyping = query.isNotEmpty;

    return BlocBuilder<AppCubit, AppState>(builder: (
      BuildContext context,
      AppState appState,
    ) {
      final String dictionaryName =
          context.read<AppCubit>().getDictionaryName();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: <Widget>[
            SearchBar(
              controller: _controller,
              elevation: const WidgetStatePropertyAll<double?>(0.2),
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 8.0),
              ),
              leading: const Icon(Icons.search),
              trailing: isTyping
                  ? <Widget>[
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            query = '';
                          });
                        },
                      ),
                    ]
                  : <Widget>[
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {},
                      ),
                    ],
              onChanged: (String text) {
                setState(() {
                  query = text;
                });
                context.read<SearchBloc>().search(text, dictionaryName);
              },
            ),
            // <- You can define this widget below
          ],
        ),
      );
    });
  }
}
