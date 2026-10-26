import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('saved words with non-ASCII keys', () {
    late Database db;

    const Word england = Word(
      id: 'az-1',
      key: 'İngiltərə',
      value: '1. das England',
      dicType: 'AzDe',
    );
    const Word ubel = Word(
      id: 'de-1',
      key: 'das Übel',
      value: '1. yamanlıq',
      dicType: 'DeAz',
    );

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      for (final String table in <String>[
        'bookmark',
        'unknown_words',
        'listened_words',
      ]) {
        await db.execute('''
          CREATE TABLE $table (
            key TEXT, value TEXT, date DATETIME DEFAULT CURRENT_TIMESTAMP,
            type TEXT, word_id TEXT, PRIMARY KEY (key, value)
          )
        ''');
      }
      DBHelper.database = db;
    });

    tearDown(() async {
      DBHelper.database = null;
      await db.close();
    });

    test('a bookmark is found, loaded and removed again', () async {
      for (final Word word in <Word>[england, ubel]) {
        await DBHelper.addBookmark(word);

        check(await DBHelper.isBookmarked(word)).isTrue();
        check((await DBHelper.getBookmark(word.key))?.key).equals(word.key);

        await DBHelper.removeBookmark(word);

        check(await DBHelper.isBookmarked(word)).isFalse();
        check(await DBHelper.getBookmark(word.key)).isNull();
      }
    });

    test('an unknown word is found, loaded and removed again', () async {
      await DBHelper.addUnknownWord(england);

      check(await DBHelper.isUnknownWord(england)).isTrue();
      check((await DBHelper.getUnknownWord(england.key))?.key)
          .equals(england.key);

      await DBHelper.removeUnknownWord(england);

      check(await DBHelper.isUnknownWord(england)).isFalse();
    });

    test('a listened word is found, loaded and removed again', () async {
      await DBHelper.addListenedWord(ubel);

      check(await DBHelper.isListenedWord(ubel)).isTrue();
      check((await DBHelper.getListenedWord(ubel.key))?.key).equals(ubel.key);

      await DBHelper.removeListenedWord(ubel);

      check(await DBHelper.isListenedWord(ubel)).isFalse();
    });

    test('ASCII keys still match regardless of case', () async {
      const Word haus = Word(
        id: 'de-2',
        key: 'das Haus',
        value: '1. ev',
        dicType: 'DeAz',
      );
      await DBHelper.addBookmark(haus);

      check((await DBHelper.getBookmark('DAS HAUS'))?.key).equals('das Haus');
    });
  });
}
