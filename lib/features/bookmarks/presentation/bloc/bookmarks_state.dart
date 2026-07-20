part of bookmarks;

abstract class BookmarksState {}

class BookmarksInitial extends BookmarksState {}

class BookmarksLoading extends BookmarksState {}

class BookmarksLoaded extends BookmarksState {
  final List<Word> bookmarks;

  BookmarksLoaded(this.bookmarks);
}

class BookmarksError extends BookmarksState {
  final String message;

  BookmarksError(this.message);
}
