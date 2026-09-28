part of search;

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {
  final List<String> recentQueries;
  SearchInitial({this.recentQueries = const <String>[]});
}

class SearchFillField extends SearchState {
  final String query;
  SearchFillField(this.query);
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Word> words;
  final String query;

  SearchLoaded(this.words, this.query);
}

class SearchError extends SearchState {}
