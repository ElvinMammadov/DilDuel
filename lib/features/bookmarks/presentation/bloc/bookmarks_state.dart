part of bookmarks;

abstract class BookmarksState {}

class BookmarksInitial extends BookmarksState {}

class BookmarksLoading extends BookmarksState {}

class BookmarksLoaded extends BookmarksState {
  final List<Word> bookmarks;
  final List<Word> unknownWords;

  BookmarksLoaded(this.bookmarks, {this.unknownWords = const <Word>[]});
}

class BookmarksError extends BookmarksState {
  final String message;

  BookmarksError(this.message);
}
