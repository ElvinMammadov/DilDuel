part of search;

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Word> words;

  SearchLoaded(this.words);
}

class SearchError extends SearchState {
}