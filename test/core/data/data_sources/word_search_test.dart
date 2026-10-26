import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('word search', () {
    late Database db;

    Future<void> insert(String table, List<String> keys) async {
      for (final String key in keys) {
        await db.insert(table, <String, Object?>{
          'id': key,
          'key': key,
          'value': '1. $key',
        });
      }
    }

    Future<List<String>> keysFor(String query, String table) async =>
        (await DBHelper.searchIn(
          db,
          query,
          table,
        )).map((Word word) => word.key).toList();

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('CREATE TABLE DeAz (id TEXT, key TEXT, value TEXT)');
      await db.execute('CREATE TABLE AzDe (id TEXT, key TEXT, value TEXT)');
    });

    tearDown(() => db.close());

    test('puts the exact word first, ignoring its article', () async {
      await insert('DeAz', <String>[
        'haushalten',
        'das Bauernhaus',
        'der Hausarzt',
        'das Haus',
        'das Haustier',
      ]);

      check(await keysFor('haus', 'DeAz')).deepEquals(<String>[
        'das Haus',
        'der Hausarzt',
        'haushalten',
        'das Haustier',
        'das Bauernhaus',
      ]);
    });

    test('matches a query that includes the article', () async {
      await insert('DeAz', <String>['das Haustier', 'das Haus']);

      check(await keysFor('Das Haus', 'DeAz')).deepEquals(<String>[
        'das Haus',
        'das Haustier',
      ]);
    });

    test('finds German words that start with a capital umlaut', () async {
      await insert('DeAz', <String>['grübeln', 'das Übel', 'übel']);

      check(await keysFor('übel', 'DeAz')).deepEquals(<String>[
        'das Übel',
        'übel',
        'grübeln',
      ]);
      check(await keysFor('ÜBEL', 'DeAz')).deepEquals(<String>[
        'das Übel',
        'übel',
        'grübeln',
      ]);
    });

    test('finds Azerbaijani words that start with a capital letter', () async {
      await insert('AzDe', <String>[
        'çin',
        'Çin',
        'Əfqanıstan',
        'İngiltərə',
        'Özbəkistan',
      ]);

      check(await keysFor('çin', 'AzDe')).deepEquals(<String>['Çin', 'çin']);
      check(await keysFor('Çin', 'AzDe')).deepEquals(<String>['Çin', 'çin']);
      check(await keysFor('əfqanıstan', 'AzDe')).deepEquals(<String>[
        'Əfqanıstan',
      ]);
      check(await keysFor('ingiltərə', 'AzDe')).deepEquals(<String>[
        'İngiltərə',
      ]);
      check(await keysFor('İNGİLTƏRƏ', 'AzDe')).deepEquals(<String>[
        'İngiltərə',
      ]);
      check(await keysFor('özbək', 'AzDe')).deepEquals(<String>[
        'Özbəkistan',
      ]);
    });

    test('does not strip articles in the Azerbaijani dictionary', () async {
      await insert('AzDe', <String>['das', 'dastan']);

      check(await keysFor('das', 'AzDe')).deepEquals(<String>[
        'das',
        'dastan',
      ]);
    });

    test('returns every word, ordered by key, for an empty query', () async {
      await insert('DeAz', <String>['der Zug', 'das Haus', 'Abend']);

      check(await keysFor('', 'DeAz')).deepEquals(<String>[
        'Abend',
        'das Haus',
        'der Zug',
      ]);
    });

    test('returns nothing when no key contains the query', () async {
      await insert('DeAz', <String>['das Haus']);

      check(await keysFor('qwertz', 'DeAz')).isEmpty();
    });
  });
}
