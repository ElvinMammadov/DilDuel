part of search;

@injectable
class SearchBloc extends Cubit<SearchState> {
  final SearchWord searchWord;

  SearchBloc({required this.searchWord}) : super(SearchInitial());

  Future<void> search(String query, String dicType) async {
    if (query.trim().isEmpty) return;
    emit(SearchLoading());
    final dartz.Either<Failure, List<Word>> result =
        await searchWord(query, dicType);
    result.fold(
      (Failure failure) => emit(SearchError()),
      (List<Word> words) => emit(SearchLoaded(words, query)),
    );
  }

  Future<void> clear(String dicType) async {
    final List<String> recents = await DBHelper.getRecentSearches(dicType);
    emit(SearchInitial(recentQueries: recents));
  }

  Future<void> saveSearch(String query, String dicType) =>
      DBHelper.saveRecentSearch(query.trim(), dicType);

  void recentTapped(String query) => emit(SearchFillField(query));
}
