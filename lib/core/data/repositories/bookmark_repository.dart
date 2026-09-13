import 'package:flutter_dic/features/search/domain/entities/word.dart';

/// Contract for all bookmark and unknown-word persistence.
abstract class BookmarkRepository {
  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> addBookmark(Word word);
  Future<void> removeBookmark(Word word);
  Future<bool> isBookmarked(Word word);
  Future<List<String>> getAllBookmarks();
  Future<Word?> getBookmark(String key);

  // ── Unknown words ─────────────────────────────────────────────────────────

  Future<void> addUnknownWord(Word word);
  Future<void> removeUnknownWord(Word word);
  Future<bool> isUnknownWord(Word word);
  Future<List<String>> getAllUnknownWords();
  Future<Word?> getUnknownWord(String key);
}
