import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('addColumnIfMissing', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute('CREATE TABLE bookmark (key TEXT, value TEXT)');
    });

    tearDown(() => db.close());

    Future<List<Object?>> columnNames() async => (await db.rawQuery(
      'PRAGMA table_info(bookmark)',
    )).map((Map<String, Object?> row) => row['name']).toList();

    test('adds a missing column', () async {
      await DBHelper.addColumnIfMissing(db, 'bookmark', 'word_id', 'TEXT');

      check(await columnNames()).deepEquals(<Object?>[
        'key',
        'value',
        'word_id',
      ]);
    });

    test('does nothing, and does not fail, when the column exists', () async {
      await DBHelper.addColumnIfMissing(db, 'bookmark', 'word_id', 'TEXT');
      await DBHelper.addColumnIfMissing(db, 'bookmark', 'word_id', 'TEXT');

      check(await columnNames()).length.equals(3);
    });
  });
}
