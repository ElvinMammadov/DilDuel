part of bookmarks;

abstract class BookmarksState {}

class BookmarksInitial extends BookmarksState {}

class BookmarksLoading extends BookmarksState {}

class BookmarksLoaded extends BookmarksState {
  final List<Word> bookmarks;
  final List<Word> unknownWords;
  final List<Word> listenedWords;

  BookmarksLoaded(
    this.bookmarks, {
    this.unknownWords = const <Word>[],
    this.listenedWords = const <Word>[],
  });
}

class BookmarksError extends BookmarksState {
  final String message;

  BookmarksError(this.message);
}
