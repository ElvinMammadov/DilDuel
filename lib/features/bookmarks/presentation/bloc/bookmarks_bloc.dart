part of bookmarks;

@injectable
class BookmarksBloc extends Cubit<BookmarksState> {
  BookmarksBloc(this._repository) : super(BookmarksInitial());

  final BookmarkRepository _repository;

  Future<void> loadBookmarks() async {
    emit(BookmarksLoading());
    try {
      final List<List<String>> keyLists = await Future.wait(
        <Future<List<String>>>[
          _repository.getAllBookmarks(),
          _repository.getAllUnknownWords(),
          _repository.getAllListenedWords(),
        ],
      );

      final List<String> bookmarkKeys = keyLists[0];
      final List<String> unknownKeys = keyLists[1];
      final List<String> listenedKeys = keyLists[2];

      final List<Word> bookmarks = <Word>[];
      for (final String key in bookmarkKeys) {
        final Word? word = await _repository.getBookmark(key);
        if (word != null) bookmarks.add(word);
      }

      final List<Word> unknownWords = <Word>[];
      for (final String key in unknownKeys) {
        final Word? word = await _repository.getUnknownWord(key);
        if (word != null) unknownWords.add(word);
      }

      final List<Word> listenedWords = <Word>[];
      for (final String key in listenedKeys) {
        final Word? word = await _repository.getListenedWord(key);
        if (word != null) listenedWords.add(word);
      }

      emit(BookmarksLoaded(
        bookmarks,
        unknownWords: unknownWords,
        listenedWords: listenedWords,
      ));
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> addBookmark(Word word) async {
    try {
      await _repository.addBookmark(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> removeBookmark(Word word) async {
    try {
      await _repository.removeBookmark(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> addUnknownWord(Word word) async {
    try {
      await _repository.addUnknownWord(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> removeUnknownWord(Word word) async {
    try {
      await _repository.removeUnknownWord(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }

  Future<void> removeListenedWord(Word word) async {
    try {
      await _repository.removeListenedWord(word);
      await loadBookmarks();
    } catch (e) {
      emit(BookmarksError(e.toString()));
    }
  }
}
