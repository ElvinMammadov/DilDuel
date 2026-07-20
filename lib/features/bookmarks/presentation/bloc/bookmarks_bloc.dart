part of bookmarks;

@injectable
class BookmarksBloc extends Cubit<BookmarksState> {
  BookmarksBloc() : super(BookmarksInitial());

  Future<void> loadBookmarks() async {
    emit(BookmarksLoading());
    try {
      final List<String> bookmarkKeys = await DBHelper.getAllBookmarks();
      final List<Word> bookmarks = <Word>[];

      for (final String key in bookmarkKeys) {
        final Word? word = await DBHelper.getBookmark(key);
        if (word != null) {
          bookmarks.add(word);
        }
      }

      emit(BookmarksLoaded(bookmarks));
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> addBookmark(Word word) async {
    try {
      await DBHelper.addBookmark(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> removeBookmark(Word word) async {
    try {
      await DBHelper.removeBookmark(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }
}
