import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('dictionary text sync', () {
    late Database db;

    Map<String, Map<String, Object?>> asset(Map<String, Object?> baum) =>
        <String, Map<String, Object?>>{
          'W1': <String, Object?>{
            'key': 'der Bau',
            'value': '1. tikinti',
            'article': 'der',
            'gender': 'Masculine',
            'genitive': 'des Bau(e)s',
            'plural': 'die Bauten',
          },
          'W2': baum,
        };

    final Map<String, Object?> unchanged = <String, Object?>{
      'key': 'der Baum',
      'value': '1. ağac',
      'article': 'der',
      'gender': 'Masculine',
      'genitive': 'des Baumes',
      'plural': 'die Bäume',
    };

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('''
        CREATE TABLE DeAz (
          id TEXT, key TEXT, value TEXT, main_type TEXT, article TEXT,
          gender TEXT, genitive TEXT, plural TEXT, imperfekt TEXT,
          perfekt TEXT, comparative TEXT, superlative TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE AzDe (
          id TEXT, key TEXT, value TEXT, main_type TEXT, sub_type TEXT,
          plural TEXT
        )
      ''');
      for (final String table in <String>['bookmark', 'unknown_words']) {
        await db.execute('''
          CREATE TABLE $table (
            key TEXT, value TEXT, type TEXT, word_id TEXT,
            PRIMARY KEY (key, value)
          )
        ''');
      }
      await db.insert('DeAz', <String, Object?>{
        'id': 'W1',
        'key': 'die Bau',
        'value': '1. tikinti',
        'article': 'die',
        'gender': 'Feminine',
        'genitive': 'der Bau',
        'plural': 'die Bauten',
      });
      await db.insert('DeAz', <String, Object?>{'id': 'W2', ...unchanged});
      await db.insert('AzDe', <String, Object?>{
        'id': 'A1',
        'key': 'tə´rif',
        'value': '1. die Definition',
      });
      await db.insert('AzDe', <String, Object?>{
        'id': 'A2',
        'key': 'atom',
        'value': '1. der Atom',
      });
    });

    tearDown(() => db.close());

    Future<void> sync() => DBHelper.syncDictionaryText(
      db,
      asset(unchanged),
      <String, Map<String, Object?>>{
        'A1': <String, Object?>{'key': 'tərif', 'value': '1. die Definition'},
        'A2': <String, Object?>{'key': 'atom', 'value': '1. das Atom'},
      },
    );

    test('rewrites changed columns and leaves the rest alone', () async {
      await sync();

      final List<Map<String, Object?>> rows = await db.query(
        'DeAz',
        orderBy: 'id',
      );
      check(rows[0])
        ..containsKey('key')
        ..deepEquals(<String, Object?>{
          'id': 'W1',
          'key': 'der Bau',
          'value': '1. tikinti',
          'article': 'der',
          'gender': 'Masculine',
          'genitive': 'des Bau(e)s',
          'plural': 'die Bauten',
          'main_type': null,
          'imperfekt': null,
          'perfekt': null,
          'comparative': null,
          'superlative': null,
        });
      check(rows[1]['key']).equals('der Baum');
    });

    test('a bookmark follows the word it was saved from', () async {
      await db.insert('bookmark', <String, Object?>{
        'key': 'die Bau',
        'value': '1. tikinti',
        'type': 'DeAz',
        'word_id': 'W1',
      });

      await sync();

      final List<Map<String, Object?>> rows = await db.query('bookmark');
      check(rows).length.equals(1);
      check(rows.single['key']).equals('der Bau');
    });

    test(
      'an older bookmark without a word id is matched by its text',
      () async {
        await db.insert('bookmark', <String, Object?>{
          'key': 'die Bau',
          'value': '1. tikinti',
          'type': 'DeAz',
        });

        await sync();

        final Map<String, Object?> row = (await db.query('bookmark')).single;
        check(row['key']).equals('der Bau');
        check(row['word_id']).equals('W1');
      },
    );

    test('unknown words are updated the same way', () async {
      await db.insert('unknown_words', <String, Object?>{
        'key': 'die Bau',
        'value': '1. tikinti',
        'type': 'DeAz',
        'word_id': 'W1',
      });

      await sync();

      final Map<String, Object?> row = (await db.query('unknown_words')).single;
      check(row['key']).equals('der Bau');
    });

    test('fixes an Azerbaijani headword and its saved copies', () async {
      await db.insert('bookmark', <String, Object?>{
        'key': 'tə´rif',
        'value': '1. die Definition',
        'type': 'AzDe',
      });

      await sync();

      final Map<String, Object?> row = (await db.query(
        'AzDe',
        where: "id = 'A1'",
      )).single;
      check(row['key']).equals('tərif');
      check((await db.query('bookmark')).single['key']).equals('tərif');
    });

    test('fixes a German term and the bookmark that saved it', () async {
      await db.insert('bookmark', <String, Object?>{
        'key': 'atom',
        'value': '1. der Atom',
        'type': 'AzDe',
        'word_id': 'A2',
      });

      await sync();

      final Map<String, Object?> row = (await db.query(
        'AzDe',
        where: "id = 'A2'",
      )).single;
      check(row['value']).equals('1. das Atom');
      check((await db.query('bookmark')).single['value']).equals('1. das Atom');
    });

    test('fixes a verb form', () async {
      await db.insert('DeAz', <String, Object?>{
        'id': 'W3',
        'key': 'plärren',
        'value': '1. ağlamaq',
        'imperfekt': 'plärrte',
        'perfekt': 'geplärt (haben)',
      });

      await DBHelper.syncDictionaryText(db, <String, Map<String, Object?>>{
        'W3': <String, Object?>{
          'key': 'plärren',
          'value': '1. ağlamaq',
          'imperfekt': 'plärrte',
          'perfekt': 'geplärrt (haben)',
        },
      }, <String, Map<String, Object?>>{});

      final Map<String, Object?> row = (await db.query(
        'DeAz',
        where: "id = 'W3'",
      )).single;
      check(row['perfekt']).equals('geplärrt (haben)');
    });

    test('adds an entry the install does not have yet', () async {
      await DBHelper.syncDictionaryText(
        db,
        <String, Map<String, Object?>>{},
        <String, Map<String, Object?>>{
          'A9': <String, Object?>{
            'id': 'A9',
            'key': 'nənə və baba',
            'value': '1. die Großeltern (plural)',
            'main_type': '1. Substantiv',
            'sub_type': null,
          },
        },
      );

      final Map<String, Object?> row = (await db.query(
        'AzDe',
        where: "id = 'A9'",
      )).single;
      check(row['key']).equals('nənə və baba');
      check(row['value']).equals('1. die Großeltern (plural)');
    });

    test('fills in the plurals of Az to De translations', () async {
      await DBHelper.syncDictionaryText(
        db,
        <String, Map<String, Object?>>{},
        <String, Map<String, Object?>>{
          'A2': <String, Object?>{
            'key': 'atom',
            'value': '1. der Atom',
            'main_type': null,
            'sub_type': null,
            'plural': '1. die Atome',
          },
        },
      );

      final Map<String, Object?> row = (await db.query(
        'AzDe',
        where: "id = 'A2'",
      )).single;
      check(row['plural']).equals('1. die Atome');
    });

    test('marks a noun as plural-only', () async {
      await DBHelper.syncDictionaryText(db, <String, Map<String, Object?>>{
        'W2': <String, Object?>{
          ...unchanged,
          'main_type': 'Substantiv (Plural)',
        },
      }, <String, Map<String, Object?>>{});

      final Map<String, Object?> row = (await db.query(
        'DeAz',
        where: "id = 'W2'",
      )).single;
      check(row['main_type']).equals('Substantiv (Plural)');
    });

    test('running it twice changes nothing more', () async {
      await sync();
      final List<Map<String, Object?>> first = await db.query('DeAz');
      await sync();

      check(await db.query('DeAz')).deepEquals(first);
    });
  });

  group('bundled dictionary', () {
    late Database asset;

    setUp(() async {
      asset = await databaseFactoryFfi.openDatabase(
        File('assets/luget.db').absolute.path,
        options: OpenDatabaseOptions(readOnly: true),
      );
    });

    tearDown(() => asset.close());

    test('is stamped with the current DB version', () async {
      check(await asset.getVersion()).equals(DBHelper.dbVersion);
    });

    test('lists the plural of German nouns in Az to De', () async {
      final List<Map<String, Object?>> rows = await asset.query(
        'AzDe',
        columns: <String>['value', 'plural'],
        where: 'key = ?',
        whereArgs: <Object?>['uşaq'],
      );

      check(rows.single['value']).equals('1. das Kind');
      check(rows.single['plural']).equals('1. die Kinder');
    });

    test('has the corrected spellings and articles', () async {
      Future<int> count(String table, String key) async {
        final List<Map<String, Object?>> rows = await asset.rawQuery(
          'SELECT COUNT(*) AS n FROM $table WHERE key = ?',
          <Object?>[key],
        );
        return rows.single['n']! as int;
      }

      check(await count('DeAz', 'der Bau')).equals(1);
      check(await count('DeAz', 'die Bau')).equals(0);
      check(await count('DeAz', 'das Schweinefleisch')).equals(1);
      check(await count('DeAz', 'das Camping')).equals(1);
      check(await count('AzDe', 'uşaq')).equals(1);
      check(await count('AzDe', 'İsveçrə konfederasiyası')).equals(1);
      check(await count('AzDe', 'Ìsveçrə konfederasiyası')).equals(0);
    });
  });
}
