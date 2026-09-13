import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';

/// Bookmark repository backed by local SQLite via [DBHelper].
@lazySingleton
class LocalBookmarkRepository implements BookmarkRepository {
  @override
  Future<void> addBookmark(Word word) => DBHelper.addBookmark(word);

  @override
  Future<void> removeBookmark(Word word) => DBHelper.removeBookmark(word);

  @override
  Future<bool> isBookmarked(Word word) => DBHelper.isBookmarked(word);

  @override
  Future<List<String>> getAllBookmarks() => DBHelper.getAllBookmarks();

  @override
  Future<Word?> getBookmark(String key) => DBHelper.getBookmark(key);

  @override
  Future<void> addUnknownWord(Word word) => DBHelper.addUnknownWord(word);

  @override
  Future<void> removeUnknownWord(Word word) =>
      DBHelper.removeUnknownWord(word);

  @override
  Future<bool> isUnknownWord(Word word) => DBHelper.isUnknownWord(word);

  @override
  Future<List<String>> getAllUnknownWords() => DBHelper.getAllUnknownWords();

  @override
  Future<Word?> getUnknownWord(String key) => DBHelper.getUnknownWord(key);

  // ── Sync helper ───────────────────────────────────────────────────────────

  /// Returns every saved bookmark as a full [Word] record.
  Future<List<Word>> getAllBookmarkWords() async {
    final List<String> keys = await getAllBookmarks();
    final List<Word> words = <Word>[];
    for (final String k in keys) {
      final Word? w = await getBookmark(k);
      if (w != null) words.add(w);
    }
    return words;
  }

  /// Returns every unknown word as a full [Word] record.
  Future<List<Word>> getAllUnknownWordRecords() async {
    final List<String> keys = await getAllUnknownWords();
    final List<Word> words = <Word>[];
    for (final String k in keys) {
      final Word? w = await getUnknownWord(k);
      if (w != null) words.add(w);
    }
    return words;
  }
}
