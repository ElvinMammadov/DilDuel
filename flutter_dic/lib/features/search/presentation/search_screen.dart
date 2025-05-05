part of search;

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<SearchBloc>(
        create: (BuildContext context) => sl<SearchBloc>(),
        child: const Column(
          children: <Widget>[
            SearchSection(),
            SearchItems(),
          ],
        ),
      );
}
