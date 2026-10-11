import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('level migration', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('CREATE TABLE DeAz (id TEXT, level TEXT, key TEXT)');
      await db.execute('''
        CREATE TABLE training_progress (
          word_id TEXT NOT NULL UNIQUE, level TEXT NOT NULL,
          correct INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE training_level_position (
          level TEXT PRIMARY KEY, current_index INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE TABLE bookmark (key TEXT, value TEXT)');
      await db.insert('DeAz', <String, Object?>{
        'id': '1',
        'level': 'B2',
        'key': 'a',
      });
      await db.insert('DeAz', <String, Object?>{
        'id': '2',
        'level': 'A1',
        'key': 'b',
      });
      await db.insert('DeAz', <String, Object?>{
        'id': '3',
        'level': 'B2',
        'key': 'c',
      });
      await db.insert('training_progress', <String, Object?>{
        'word_id': '1',
        'level': 'B2',
        'correct': 4,
      });
      await db.insert('training_level_position', <String, Object?>{
        'level': 'B2',
        'current_index': 120,
      });
      await db.insert('bookmark', <String, Object?>{'key': 'a', 'value': 'x'});
    });

    tearDown(() => db.close());

    Future<String?> levelOf(String id) async =>
        (await db.query(
              'DeAz',
              where: 'id = ?',
              whereArgs: <Object?>[id],
            )).single['level']
            as String?;

    test(
      'relevels words, leaving words missing from the asset alone',
      () async {
        await DBHelper.migrateLevels(db, <String, String>{
          '1': 'C1',
          '2': 'A2',
        });

        check(await levelOf('1')).equals('C1');
        check(await levelOf('2')).equals('A2');
        check(await levelOf('3')).equals('B2');
      },
    );

    test(
      'relevels per-word training progress and keeps its counters',
      () async {
        await DBHelper.migrateLevels(db, <String, String>{'1': 'C2'});

        final Map<String, Object?> row = (await db.query(
          'training_progress',
        )).single;
        check(row['level']).equals('C2');
        check(row['correct']).equals(4);
      },
    );

    test('resets saved positions but keeps other user data', () async {
      await DBHelper.migrateLevels(db, <String, String>{'1': 'C1'});

      check(await db.query('training_level_position')).isEmpty();
      check(await db.query('bookmark')).length.equals(1);
    });
  });

  group('asset database', () {
    late Database asset;

    setUpAll(() async {
      asset = await databaseFactoryFfi.openDatabase(
        File('assets/luget.db').absolute.path,
        options: OpenDatabaseOptions(readOnly: true),
      );
    });

    tearDownAll(() => asset.close());

    test('is versioned to match the app', () async {
      check(await asset.getVersion()).equals(DBHelper.dbVersion);
    });

    test('gives every word a training level and fills each level', () async {
      final Map<String, int> counts = <String, int>{
        for (final Map<String, Object?> row in await asset.rawQuery(
          'SELECT level, COUNT(*) AS n FROM DeAz GROUP BY level',
        ))
          row['level'] as String: row['n'] as int,
      };

      check(counts.keys.toSet()).deepEquals(trainingLevels.toSet());
      check(counts.values.every((int n) => n > 0)).isTrue();
    });
  });
}
