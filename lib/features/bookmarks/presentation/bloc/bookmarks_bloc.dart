part of bookmarks;

@injectable
class BookmarksBloc extends Cubit<BookmarksState> {
  BookmarksBloc() : super(BookmarksInitial());

  Future<void> loadBookmarks() async {
    emit(BookmarksLoading());
    try {
      // Fetch both key lists in parallel.
      final List<List<String>> keyLists = await Future.wait(<Future<List<String>>>[
        DBHelper.getAllBookmarks(),
        DBHelper.getAllUnknownWords(),
      ]);

      final List<String> bookmarkKeys = keyLists[0];
      final List<String> unknownKeys = keyLists[1];

      // Resolve full Word objects (sequential per list — DB is single-file).
      final List<Word> bookmarks = <Word>[];
      for (final String key in bookmarkKeys) {
        final Word? word = await DBHelper.getBookmark(key);
        if (word != null) bookmarks.add(word);
      }

      final List<Word> unknownWords = <Word>[];
      for (final String key in unknownKeys) {
        final Word? word = await DBHelper.getUnknownWord(key);
        if (word != null) unknownWords.add(word);
      }

      emit(BookmarksLoaded(bookmarks, unknownWords: unknownWords));
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

  Future<void> addUnknownWord(Word word) async {
    try {
      await DBHelper.addUnknownWord(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> removeUnknownWord(Word word) async {
    try {
      await DBHelper.removeUnknownWord(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }
}
