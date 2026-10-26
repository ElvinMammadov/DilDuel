import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/core/data/models/answer_record.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: WordLocalDataSource)
class DBHelper implements WordLocalDataSource {
  static const String dbName = 'luget.db';

  /// Word ids per training topic, bundled next to the DB.
  static const String topicsAsset = 'assets/training_topics.json';

  /// SQLite's default limit on bound variables is 999, so ids are queried in
  /// chunks below that.
  static const int _idsPerQuery = 500;

  /// Bump this when the asset DB changes. Installs older than
  /// [_firstMigratableVersion] get the asset file re-copied; newer ones are
  /// migrated in place (see [_migrateLevels] and [_syncDictionaryText]).
  static const int dbVersion = 14;

  /// Oldest install version whose schema matches the current asset, so it
  /// can be updated without replacing the file and losing user data.
  static const int _firstMigratableVersion = 5;

  /// First version that has the A1–C2 levels.
  static const int _extendedLevelsVersion = 6;

  /// First version with corrected spellings, articles and translations in the
  /// dictionary.
  static const int _textFixesVersion = 14;

  // ── table names ──────────────────────────────────────────────────────────
  static const String deAz = 'DeAz';
  static const String azDe = 'AzDe';
  static const String bookmark = 'bookmark';
  static const String quizResults = 'quiz_results';
  static const String unknownWords = 'unknown_words';
  static const String trainingProgress = 'training_progress';
  static const String trainingLevelPosition = 'training_level_position';
  static const String listenedWords = 'listened_words';
  static const String listeningResults = 'listening_results';
  static const String quizResultAnswers = 'quiz_result_answers';
  static const String listeningResultAnswers = 'listening_result_answers';
  static const String recentSearches = 'recent_searches';

  // ── shared columns ───────────────────────────────────────────────────────
  static const String colId = 'id';
  static const String colLevel = 'level';
  static const String colKey = 'key';
  static const String colValue = 'value';
  static const String colType = 'type';

  // ── DeAz-only columns ────────────────────────────────────────────────────
  static const String colArticle = 'article';
  static const String colGender = 'gender';
  static const String colMainType = 'main_type';
  static const String colSubType = 'sub_type';
  static const String colGenitive = 'genitive';
  static const String colPlural = 'plural';
  static const String colImperfekt = 'imperfekt';
  static const String colPerfekt = 'perfekt';
  static const String colComparative = 'comparative';
  static const String colSuperlative = 'superlative';
  static const String colExample = 'example';
  static const String colSentence = 'sentence';

  static Database? _db;

  /// Replaces the open database; lets tests run the static helpers on an
  /// in-memory database.
  @visibleForTesting
  static set database(Database? database) => _db = database;

  static Future<void> _createQuizResultsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $quizResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createTrainingProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $trainingProgress(
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id   TEXT    NOT NULL,
        level     TEXT    NOT NULL,
        correct   INTEGER NOT NULL DEFAULT 0,
        incorrect INTEGER NOT NULL DEFAULT 0,
        last_seen TEXT,
        UNIQUE(word_id)
      )
    ''');
  }

  static Future<void> _createTrainingLevelPositionTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $trainingLevelPosition(
        level         TEXT PRIMARY KEY,
        current_index INTEGER NOT NULL DEFAULT 0,
        last_accessed TEXT
      )
    ''');
  }

  static Future<void> _createUnknownWordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $unknownWords(
        key     TEXT NOT NULL,
        value   TEXT NOT NULL,
        date    DATETIME DEFAULT CURRENT_TIMESTAMP,
        type    TEXT,
        word_id TEXT,
        PRIMARY KEY (key, value)
      )
    ''');
  }

  static Future<void> _createRecentSearchesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $recentSearches(
        query    TEXT NOT NULL,
        dic_type TEXT NOT NULL,
        date     TEXT NOT NULL,
        PRIMARY KEY (query, dic_type)
      )
    ''');
  }

  static Future<void> saveRecentSearch(String query, String dicType) async {
    await _db!.insert(
      recentSearches,
      <String, Object?>{
        'query': query,
        'dic_type': dicType,
        'date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _db!.execute('''
      DELETE FROM $recentSearches
      WHERE dic_type = ? AND query NOT IN (
        SELECT query FROM $recentSearches
        WHERE dic_type = ?
        ORDER BY date DESC
        LIMIT 10
      )
    ''', <Object?>[dicType, dicType]);
  }

  static Future<List<String>> getRecentSearches(String dicType) async {
    final List<Map<String, Object?>> rows = await _db!.query(
      recentSearches,
      columns: <String>['query'],
      where: 'dic_type = ?',
      whereArgs: <Object?>[dicType],
      orderBy: 'date DESC',
      limit: 10,
    );
    return rows.map((Map<String, Object?> r) => r['query'] as String).toList();
  }

  static Future<void> _createListenedWordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $listenedWords(
        key     TEXT NOT NULL,
        value   TEXT NOT NULL,
        date    DATETIME DEFAULT CURRENT_TIMESTAMP,
        type    TEXT,
        word_id TEXT,
        PRIMARY KEY (key, value)
      )
    ''');
  }

  static Future<void> _ensureTables(Database db) async {
    await _createQuizResultsTable(db);
    await _createUnknownWordsTable(db);
    await _createTrainingProgressTable(db);
    await _createTrainingLevelPositionTable(db);
    await _createListenedWordsTable(db);
    await _createRecentSearchesTable(db);
    await _createListeningResultsTable(db);
    await _createQuizResultAnswersTable(db);
    await _createListeningResultAnswersTable(db);
    await _migrateAddWordId(db);
    await _migrateAddAzDePlural(db);
  }

  /// Adds `word_id` to existing `bookmark` and `unknown_words` tables.
  static Future<void> _migrateAddWordId(Database db) async {
    for (final String table in <String>[bookmark, unknownWords]) {
      await addColumnIfMissing(db, table, 'word_id', 'TEXT');
    }
  }

  /// Adds the per-translation `plural` column to an existing `AzDe` table.
  static Future<void> _migrateAddAzDePlural(Database db) =>
      addColumnIfMissing(db, azDe, colPlural, 'TEXT');

  /// Adds [column] to [table] unless it is already there.
  ///
  /// SQLite has no `ADD COLUMN IF NOT EXISTS`, and trying the `ALTER` anyway
  /// logs a "duplicate column name" error on every launch.
  @visibleForTesting
  static Future<void> addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final List<Map<String, Object?>> columns =
        await db.rawQuery('PRAGMA table_info($table)');
    final bool exists =
        columns.any((Map<String, Object?> row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  // ── Training position helpers ─────────────────────────────────────────────

  /// Returns the saved word index for [level], or 0 if never set.
  static Future<int> getLevelPosition(String level) async {
    final List<Map<String, Object?>> rows = await _db!.query(
      trainingLevelPosition,
      columns: <String>['current_index'],
      where: 'level = ?',
      whereArgs: <Object?>[level],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return rows.first['current_index'] as int? ?? 0;
  }

  /// Persists [index] for [level] and updates the last-accessed timestamp.
  static Future<void> saveLevelPosition(String level, int index) async {
    await _db!.insert(
      trainingLevelPosition,
      <String, Object?>{
        'level': level,
        'current_index': index,
        'last_accessed': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns the level that was accessed most recently, or null if none.
  static Future<String?> getLastTrainingLevel() async {
    final List<Map<String, Object?>> rows = await _db!.query(
      trainingLevelPosition,
      columns: <String>['level'],
      orderBy: 'last_accessed DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['level'] as String?;
  }

  /// Initialises the database, re-copying the asset file when the schema
  /// is too old to migrate (detected via SQLite PRAGMA user_version).
  static Future<void> initDB() async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(documentsDir.path, dbName);

    bool needsCopy = !(await File(dbPath).exists());

    if (!needsCopy) {
      final Database existing = await openDatabase(dbPath);
      final int storedVersion = await existing.getVersion();
      await existing.close();
      if (storedVersion < _firstMigratableVersion) {
        needsCopy = true;
      }
    }

    if (needsCopy) {
      final ByteData data = await rootBundle.load('assets/$dbName');
      final Uint8List bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(
      dbPath,
      version: dbVersion,
      onCreate: (Database db, int version) async {
        await _ensureTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await _ensureTables(db);
        if (oldVersion < _extendedLevelsVersion) {
          await _migrateLevels(db, await _readAssetLevels());
        }
        if (oldVersion < _textFixesVersion) {
          final (
            Map<String, Map<String, Object?>> deAzRows,
            Map<String, Map<String, Object?>> azDeRows,
          ) = await _readAssetText();
          await _syncDictionaryText(db, deAzRows, azDeRows);
        }
      },
      onOpen: (Database db) async {
        await _ensureTables(db);
      },
    );
  }

  /// Reads `{word id: level}` from the bundled asset DB.
  static Future<Map<String, String>> _readAssetLevels() async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File(join(tempDir.path, 'luget_levels.db'));
    final ByteData data = await rootBundle.load('assets/$dbName');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    final Database asset = await openDatabase(file.path, readOnly: true);
    try {
      final List<Map<String, Object?>> rows =
          await asset.query(deAz, columns: <String>[colId, colLevel]);
      return <String, String>{
        for (final Map<String, Object?> row in rows)
          if (row[colId] case final String id)
            if (row[colLevel] case final String level) id: level,
      };
    } finally {
      await asset.close();
      await file.delete();
    }
  }

  /// `DeAz` columns that dictionary text fixes can change.
  static const List<String> _deAzTextColumns = <String>[
    colKey,
    colValue,
    colMainType,
    colArticle,
    colGender,
    colGenitive,
    colPlural,
    colImperfekt,
    colPerfekt,
    colComparative,
    colSuperlative,
  ];

  /// `AzDe` columns that dictionary text fixes can change.
  static const List<String> _azDeTextColumns = <String>[
    colKey,
    colValue,
    colMainType,
    colSubType,
    colPlural,
  ];

  /// Reads the fixable text columns of every `DeAz` and `AzDe` row, by word
  /// id, from the bundled asset DB.
  static Future<
      (
        Map<String, Map<String, Object?>>,
        Map<String, Map<String, Object?>>,
      )> _readAssetText() async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File(join(tempDir.path, 'luget_text.db'));
    final ByteData data = await rootBundle.load('assets/$dbName');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    final Database asset = await openDatabase(file.path, readOnly: true);
    try {
      return (
        await _readTextColumns(asset, deAz, _deAzTextColumns),
        await _readTextColumns(asset, azDe, _azDeTextColumns),
      );
    } finally {
      await asset.close();
      await file.delete();
    }
  }

  static Future<Map<String, Map<String, Object?>>> _readTextColumns(
    Database db,
    String table,
    List<String> columns,
  ) async {
    final List<Map<String, Object?>> rows = await db.query(
      table,
      columns: <String>[colId, ...columns],
    );
    return <String, Map<String, Object?>>{
      for (final Map<String, Object?> row in rows)
        if (row[colId] case final String id) id: row,
    };
  }

  /// Brings the dictionary text of an existing install in line with the
  /// bundled asset, so corrected spellings, articles and headwords reach
  /// users without replacing the file.
  ///
  /// Bookmarks and unknown words keep their own copy of a word's key and
  /// meaning, so the ones that point at a changed word are updated too.
  @visibleForTesting
  static Future<void> syncDictionaryText(
    Database db,
    Map<String, Map<String, Object?>> deAzRows,
    Map<String, Map<String, Object?>> azDeRows,
  ) =>
      _syncDictionaryText(db, deAzRows, azDeRows);

  static Future<void> _syncDictionaryText(
    Database db,
    Map<String, Map<String, Object?>> deAzRows,
    Map<String, Map<String, Object?>> azDeRows,
  ) async {
    final Batch batch = db.batch();
    await _queueTextChanges(batch, db, deAz, _deAzTextColumns, deAzRows);
    await _queueTextChanges(
      batch,
      db,
      azDe,
      _azDeTextColumns,
      azDeRows,
      insertMissing: true,
    );
    await batch.commit(noResult: true);
  }

  /// Queues an update for every row of [table] whose [columns] differ from
  /// [wantedRows], plus the saved copies of the words whose key or meaning
  /// changed. With [insertMissing], rows the install does not have yet are
  /// added as well.
  static Future<void> _queueTextChanges(
    Batch batch,
    Database db,
    String table,
    List<String> columns,
    Map<String, Map<String, Object?>> wantedRows, {
    bool insertMissing = false,
  }) async {
    final List<Map<String, Object?>> current = await db.query(
      table,
      columns: <String>[colId, ...columns],
    );
    for (final Map<String, Object?> row in current) {
      final Map<String, Object?>? wanted = wantedRows[row[colId]];
      if (wanted == null) continue;
      final Map<String, Object?> changes = <String, Object?>{
        for (final String column in columns)
          if (row[column] != wanted[column]) column: wanted[column],
      };
      if (changes.isEmpty) continue;
      batch.update(
        table,
        changes,
        where: '$colId = ?',
        whereArgs: <Object?>[row[colId]],
      );
      if (changes.containsKey(colKey) || changes.containsKey(colValue)) {
        _updateSavedWords(
          batch,
          values: <String, Object?>{
            colKey: wanted[colKey],
            colValue: wanted[colValue],
            'word_id': row[colId],
          },
          where: '$colType = ? AND (word_id = ? OR '
              '(word_id IS NULL AND $colKey = ? AND $colValue = ?))',
          whereArgs: <Object?>[
            table,
            row[colId],
            row[colKey],
            row[colValue],
          ],
        );
      }
    }
    if (insertMissing) {
      final Set<Object?> existing = <Object?>{
        for (final Map<String, Object?> row in current) row[colId],
      };
      for (final MapEntry<String, Map<String, Object?>> entry
          in wantedRows.entries) {
        if (!existing.contains(entry.key)) batch.insert(table, entry.value);
      }
    }
  }

  /// Queues [values] for the matching rows of both tables that keep a copy
  /// of a word. A row that would collide with an existing one is left alone.
  static void _updateSavedWords(
    Batch batch, {
    required Map<String, Object?> values,
    required String where,
    required List<Object?> whereArgs,
  }) {
    for (final String table in <String>[bookmark, unknownWords]) {
      batch.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Applies [levels] to an existing install without replacing the file, so
  /// bookmarks, results and per-word progress survive.
  ///
  /// Saved training positions are indexes into the per-level word lists,
  /// which now hold different words, so they are reset.
  @visibleForTesting
  static Future<void> migrateLevels(
    Database db,
    Map<String, String> levels,
  ) =>
      _migrateLevels(db, levels);

  static Future<void> _migrateLevels(
    Database db,
    Map<String, String> levels,
  ) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_deaz_id ON $deAz($colId)');
    final Batch batch = db.batch();
    levels.forEach((String id, String level) {
      batch.update(
        deAz,
        <String, Object?>{colLevel: level},
        where: '$colId = ?',
        whereArgs: <Object?>[id],
      );
    });
    batch.execute('''
      UPDATE $trainingProgress
      SET level = (
        SELECT $deAz.$colLevel FROM $deAz
        WHERE $deAz.$colId = $trainingProgress.word_id
      )
      WHERE word_id IN (SELECT $colId FROM $deAz)
    ''');
    batch.delete(trainingLevelPosition);
    await batch.commit(noResult: true);
  }

  static const int _deAzTypeValue = 321;

  static String getTableName(int dicType) =>
      dicType == _deAzTypeValue ? deAz : azDe;

  static Future<List<String>> getWords(int dicType) async {
    final String tableName = getTableName(dicType);
    final List<Map<String, Object?>> result = await _db!.query(tableName);
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  /// Upper-case letters that SQLite's ASCII-only `LOWER()` leaves untouched,
  /// with the lower-case form they should match. `İ` folds to a plain `i` so
  /// that `ingiltərə` finds `İngiltərə`.
  static const Map<String, String> _foldedLetters = <String, String>{
    'Ä': 'ä',
    'Ö': 'ö',
    'Ü': 'ü',
    'Ə': 'ə',
    'Ç': 'ç',
    'Ş': 'ş',
    'Ğ': 'ğ',
    'İ': 'i',
  };

  /// German nouns are stored with their article (`das Haus`).
  static const List<String> _articles = <String>['der', 'die', 'das'];

  /// Lower-cases [text] exactly as [_foldedSql] lower-cases a column.
  static String _foldCase(String text) {
    String folded = text;
    _foldedLetters.forEach((String upper, String lower) {
      folded = folded.replaceAll(upper, lower);
    });
    return folded.toLowerCase();
  }

  static String _foldedSql(String column) {
    String expression = column;
    _foldedLetters.forEach((String upper, String lower) {
      expression = "REPLACE($expression, '$upper', '$lower')";
    });
    return 'LOWER($expression)';
  }

  /// SQL for [foldedColumn] without a leading article, so `haus` ranks
  /// `das Haus` as a word starting with `haus`.
  static String _withoutArticleSql(String foldedColumn) {
    final String cases = _articles
        .map(
          (String article) =>
              "WHEN $foldedColumn LIKE '$article %' "
              'THEN SUBSTR($foldedColumn, ${article.length + 2})',
        )
        .join(' ');
    return 'CASE $cases ELSE $foldedColumn END';
  }

  @override
  Future<List<Word>> searchWords(String key, String dicType) =>
      searchIn(_db!, key, dicType);

  /// Finds the words of [dicType] whose key contains [key], ignoring case
  /// (including `Ä Ö Ü Ə Ç Ş Ğ İ`) and any leading article. An exact match
  /// comes first, then words starting with [key], then the rest.
  @visibleForTesting
  static Future<List<Word>> searchIn(
    Database db,
    String key,
    String dicType,
  ) async {
    final String query = _foldCase(key);
    final String bareKey = dicType == deAz
        ? _withoutArticleSql('folded_key')
        : 'folded_key';

    final List<Map<String, Object?>> result = query.isEmpty
        ? await db.query(dicType, orderBy: 'key ASC')
        : await db.rawQuery('''
            SELECT * FROM (
              SELECT *, $bareKey AS bare_key FROM (
                SELECT *, ${_foldedSql('key')} AS folded_key FROM $dicType
              )
            )
            WHERE folded_key LIKE ?
            ORDER BY
              CASE
                WHEN bare_key = ? OR folded_key = ? THEN 0
                WHEN bare_key LIKE ? OR folded_key LIKE ? THEN 1
                ELSE 2
              END,
              bare_key,
              key
          ''', <Object?>['%$query%', query, query, '$query%', '$query%']);

    return result.map((Map<String, Object?> row) {
      final bool isDeAz = dicType == deAz;
      return Word(
        id: row[colId] as String?,
        key: row[colKey] as String? ?? '',
        value: row[colValue] as String? ?? '',
        dicType: dicType,
        article: isDeAz ? row[colArticle] as String? : null,
        gender: isDeAz ? row[colGender] as String? : null,
        mainType: row[colMainType] as String?,
        subType: row[colSubType] as String?,
        genitive: isDeAz ? row[colGenitive] as String? : null,
        plural: isDeAz ? row[colPlural] as String? : null,
        imperfekt: isDeAz ? row[colImperfekt] as String? : null,
        perfekt: isDeAz ? row[colPerfekt] as String? : null,
        comparative: isDeAz ? row[colComparative] as String? : null,
        superlative: isDeAz ? row[colSuperlative] as String? : null,
        example: isDeAz ? row[colExample] as String? : null,
        sentence: isDeAz ? row[colSentence] as String? : null,
        translationPlurals: isDeAz ? null : row[colPlural] as String?,
      );
    }).toList();
  }

  /// Returns the total number of [Word]s in [deAz] for the given CEFR [level].
  static Future<int> getWordCountByLevel(String level) async {
    final List<Map<String, Object?>> result = await _db!.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $deAz WHERE $colLevel = ?',
      <Object?>[level],
    );
    if (result.isEmpty) return 0;
    final Object? v = result.first['cnt'];
    return v is int ? v : 0;
  }

  /// Returns all [Word]s from [deAz] that have the given CEFR [level].
  ///
  /// Rows come back in insertion order, which keeps the list stable so a
  /// caller can apply a reproducible shuffle on top of it.
  static Future<List<Word>> getWordsByLevel(String level) async {
    final List<Map<String, Object?>> result = await _db!.query(
      deAz,
      where: '$colLevel = ?',
      whereArgs: <Object?>[level],
      orderBy: 'rowid',
    );
    return result.map(_wordFromRow).toList();
  }

  static Map<String, List<String>>? _topicWordIds;

  static Future<Map<String, List<String>>> _loadTopicWordIds() async =>
      _topicWordIds ??= <String, List<String>>{
        for (final MapEntry<String, dynamic> entry
            in (jsonDecode(await rootBundle.loadString(topicsAsset))
                    as Map<String, dynamic>)
                .entries)
          entry.key: List<String>.from(entry.value as List<dynamic>),
      };

  /// Returns the number of words in the training [topic].
  static Future<int> getWordCountByTopic(String topic) async =>
      (await _loadTopicWordIds())[topic]?.length ?? 0;

  /// Returns the words of the training [topic] grouped by CEFR level, easiest
  /// level first. Within a level the words keep their insertion order, so a
  /// caller can apply a reproducible shuffle per level.
  static Future<Map<String, List<Word>>> getWordsByTopic(String topic) async {
    final List<String> ids = (await _loadTopicWordIds())[topic] ?? <String>[];
    final Map<String, List<Word>> byLevel = <String, List<Word>>{};
    for (int start = 0; start < ids.length; start += _idsPerQuery) {
      final List<String> chunk = ids.sublist(
        start,
        (start + _idsPerQuery).clamp(0, ids.length),
      );
      final String placeholders =
          List<String>.filled(chunk.length, '?').join(',');
      final List<Map<String, Object?>> rows = await _db!.query(
        deAz,
        where: '$colId IN ($placeholders)',
        whereArgs: chunk,
        orderBy: 'rowid',
      );
      for (final Map<String, Object?> row in rows) {
        byLevel
            .putIfAbsent(row[colLevel] as String? ?? '', () => <Word>[])
            .add(_wordFromRow(row));
      }
    }
    return <String, List<Word>>{
      for (final String level in trainingLevels)
        if (byLevel[level] case final List<Word> words) level: words,
    };
  }

  static Word _wordFromRow(Map<String, Object?> row) => Word(
        id: row[colId] as String?,
        key: row[colKey] as String? ?? '',
        value: row[colValue] as String? ?? '',
        dicType: deAz,
        article: row[colArticle] as String?,
        gender: row[colGender] as String?,
        mainType: row[colMainType] as String?,
        subType: row[colSubType] as String?,
        genitive: row[colGenitive] as String?,
        plural: row[colPlural] as String?,
        imperfekt: row[colImperfekt] as String?,
        perfekt: row[colPerfekt] as String?,
        comparative: row[colComparative] as String?,
        superlative: row[colSuperlative] as String?,
        example: row[colExample] as String?,
        sentence: row[colSentence] as String?,
      );

  /// Returns the full [Word] from the dictionary table for an exact key match.
  ///
  /// Falls back to `null` when the word is not found (e.g. the DB was updated
  /// after the bookmark was saved).
  static Future<Word?> getWordByKey(String key, String dicType) async {
    final List<Map<String, Object?>> result = await _db!.query(
      dicType,
      where: 'key = ? COLLATE NOCASE',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final Map<String, Object?> row = result.first;
    final bool isDeAz = dicType == deAz;
    return Word(
      id: row[colId] as String?,
      key: row[colKey] as String? ?? '',
      value: row[colValue] as String? ?? '',
      dicType: dicType,
      article: isDeAz ? row[colArticle] as String? : null,
      gender: isDeAz ? row[colGender] as String? : null,
      mainType: row[colMainType] as String?,
      subType: row[colSubType] as String?,
      genitive: isDeAz ? row[colGenitive] as String? : null,
      plural: isDeAz ? row[colPlural] as String? : null,
      imperfekt: isDeAz ? row[colImperfekt] as String? : null,
      perfekt: isDeAz ? row[colPerfekt] as String? : null,
      comparative: isDeAz ? row[colComparative] as String? : null,
      superlative: isDeAz ? row[colSuperlative] as String? : null,
      example: isDeAz ? row[colExample] as String? : null,
      sentence: isDeAz ? row[colSentence] as String? : null,
      translationPlurals: isDeAz ? null : row[colPlural] as String?,
    );
  }

  // Saved words are matched on their exact key. `COLLATE NOCASE` keeps the
  // match case-insensitive for ASCII, but must not be replaced by
  // `UPPER(key)`: SQLite only upper-cases ASCII, so keys with letters such as
  // `ə` or `ü` would never equal their Dart-uppercased form.
  static Future<void> addBookmark(Word word) async {
    await _db!.insert(
      bookmark,
      <String, Object?>{
        colKey: word.key,
        colValue: word.value,
        colType: word.dicType,
        'word_id': word.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeBookmark(Word word) async {
    await _db!.delete(
      bookmark,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
  }

  static Future<void> removeBookmarkByKey(String key) async {
    await _db!.delete(
      bookmark,
      where: 'key = ? COLLATE NOCASE',
      whereArgs: <Object?>[key],
    );
  }

  static Future<List<String>> getAllBookmarks() async {
    final List<Map<String, Object?>> result =
        await _db!.query(bookmark, orderBy: 'date DESC');
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  static Future<bool> isBookmarked(Word word) async {
    final List<Map<String, Object?>> result = await _db!.query(
      bookmark,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
    return result.isNotEmpty;
  }

  static Future<Word?> getBookmark(String key) async {
    final List<Map<String, Object?>> result = await _db!.query(
      bookmark,
      where: 'key = ? COLLATE NOCASE',
      whereArgs: <Object?>[key],
    );
    if (result.isEmpty) return null;
    final Map<String, Object?> row = result.first;
    return Word(
      id: row['word_id'] as String?,
      key: row[colKey] as String? ?? '',
      value: row[colValue] as String? ?? '',
      dicType: row[colType] as String? ?? '',
    );
  }

  static Future<void> clearBookmarks() async {
    await _db!.delete(bookmark);
  }

  // ── Unknown-word methods ──────────────────────────────────────────────────

  static Future<void> addUnknownWord(Word word) async {
    await _db!.insert(
      unknownWords,
      <String, Object?>{
        colKey: word.key,
        colValue: word.value,
        colType: word.dicType,
        'word_id': word.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeUnknownWord(Word word) async {
    await _db!.delete(
      unknownWords,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
  }

  static Future<bool> isUnknownWord(Word word) async {
    final List<Map<String, Object?>> result = await _db!.query(
      unknownWords,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
    return result.isNotEmpty;
  }

  static Future<List<String>> getAllUnknownWords() async {
    final List<Map<String, Object?>> result =
        await _db!.query(unknownWords, orderBy: 'date DESC');
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  static Future<Word?> getUnknownWord(String key) async {
    final List<Map<String, Object?>> result = await _db!.query(
      unknownWords,
      where: 'key = ? COLLATE NOCASE',
      whereArgs: <Object?>[key],
    );
    if (result.isEmpty) return null;
    final Map<String, Object?> row = result.first;
    return Word(
      id: row['word_id'] as String?,
      key: row[colKey] as String? ?? '',
      value: row[colValue] as String? ?? '',
      dicType: row[colType] as String? ?? '',
    );
  }

  // ── Listened-word methods ─────────────────────────────────────────────────

  static Future<void> addListenedWord(Word word) async {
    await _db!.insert(
      listenedWords,
      <String, Object?>{
        colKey: word.key,
        colValue: word.value,
        colType: word.dicType,
        'word_id': word.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeListenedWord(Word word) async {
    await _db!.delete(
      listenedWords,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
  }

  static Future<bool> isListenedWord(Word word) async {
    final List<Map<String, Object?>> result = await _db!.query(
      listenedWords,
      where: 'key = ? COLLATE NOCASE AND value = ?',
      whereArgs: <Object?>[word.key, word.value],
    );
    return result.isNotEmpty;
  }

  static Future<List<String>> getAllListenedWords() async {
    final List<Map<String, Object?>> result =
        await _db!.query(listenedWords, orderBy: 'date DESC');
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  static Future<Word?> getListenedWord(String key) async {
    final List<Map<String, Object?>> result = await _db!.query(
      listenedWords,
      where: 'key = ? COLLATE NOCASE',
      whereArgs: <Object?>[key],
    );
    if (result.isEmpty) return null;
    final Map<String, Object?> row = result.first;
    return Word(
      id: row['word_id'] as String?,
      key: row[colKey] as String? ?? '',
      value: row[colValue] as String? ?? '',
      dicType: row[colType] as String? ?? '',
    );
  }

  // ── Listening result methods ──────────────────────────────────────────────

  static Future<void> _createListeningResultsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $listeningResults(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createQuizResultAnswersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $quizResultAnswers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        given_answer TEXT NOT NULL,
        is_correct INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createListeningResultAnswersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $listeningResultAnswers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        given_answer TEXT NOT NULL,
        is_correct INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> insertListeningResult(QuizResult result) async {
    await _db!.transaction((Transaction txn) async {
      final int id = await txn.insert(listeningResults, <String, dynamic>{
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'dateTime': result.dateTime.toIso8601String(),
      });
      for (final AnswerRecord a in result.answers) {
        await txn.insert(listeningResultAnswers, <String, dynamic>{
          'result_id': id,
          'question': a.question,
          'correct_answer': a.correctAnswer,
          'given_answer': a.givenAnswer,
          'is_correct': a.isCorrect ? 1 : 0,
        });
      }
    });
  }

  static Future<List<QuizResult>> getListeningResults() async {
    final List<Map<String, dynamic>> maps =
        await _db!.query(listeningResults, orderBy: 'dateTime DESC');
    final List<QuizResult> results = <QuizResult>[];
    for (final Map<String, dynamic> map in maps) {
      final int id = map['id'] as int;
      final List<Map<String, dynamic>> answerMaps = await _db!.query(
        listeningResultAnswers,
        where: 'result_id = ?',
        whereArgs: <Object?>[id],
      );
      final List<AnswerRecord> answers =
          answerMaps.map(AnswerRecord.fromMap).toList();
      results.add(QuizResult(
        id: id,
        score: map['score'] as int,
        totalQuestions: map['totalQuestions'] as int,
        dateTime: DateTime.parse(map['dateTime'] as String),
        answers: answers,
      ));
    }
    return results;
  }

  static Future<Map<String, dynamic>> getListeningStatistics() async {
    final List<Map<String, dynamic>> results = await _db!.rawQuery('''
      SELECT
        COUNT(*) as totalSessions,
        AVG(CAST(score AS FLOAT) / CAST(totalQuestions AS FLOAT) * 100)
          as averageScore
      FROM $listeningResults
    ''');
    return <String, dynamic>{
      'totalSessions': results[0]['totalSessions'] as int,
      'averageScore':
          (results[0]['averageScore'] as double?)?.toStringAsFixed(1) ?? '0.0',
    };
  }

  // ── Quiz methods ──────────────────────────────────────────────────────────

  static Future<void> insertQuizResult(QuizResult result) async {
    await _db!.transaction((Transaction txn) async {
      final int id = await txn.insert(quizResults, result.toMap());
      for (final AnswerRecord a in result.answers) {
        await txn.insert(quizResultAnswers, <String, dynamic>{
          'result_id': id,
          'question': a.question,
          'correct_answer': a.correctAnswer,
          'given_answer': a.givenAnswer,
          'is_correct': a.isCorrect ? 1 : 0,
        });
      }
    });
  }

  static Future<List<QuizResult>> getQuizResults() async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      quizResults,
      orderBy: 'dateTime DESC',
    );
    final List<QuizResult> results = <QuizResult>[];
    for (final Map<String, dynamic> map in maps) {
      final int id = map['id'] as int;
      final List<Map<String, dynamic>> answerMaps = await _db!.query(
        quizResultAnswers,
        where: 'result_id = ?',
        whereArgs: <Object?>[id],
      );
      final List<AnswerRecord> answers =
          answerMaps.map(AnswerRecord.fromMap).toList();
      results.add(QuizResult.fromMap(map, answers: answers));
    }
    return results;
  }

  static Future<Map<String, dynamic>> getQuizStatistics() async {
    final List<Map<String, dynamic>> results = await _db!.rawQuery('''
      SELECT
        COUNT(*) as totalQuizzes,
        AVG(CAST(score AS FLOAT) / CAST(totalQuestions AS FLOAT) * 100)
          as averageScore
      FROM $quizResults
    ''');
    return <String, dynamic>{
      'totalQuizzes': results[0]['totalQuizzes'] as int,
      'averageScore':
          (results[0]['averageScore'] as double?)?.toStringAsFixed(1) ?? '0.0',
    };
  }

  // ── User data lifecycle ───────────────────────────────────────────────────

  /// Deletes all user-specific rows from every synced table.
  ///
  /// Call this on sign-out so that the next user to sign in on the same
  /// device starts with a clean local state and their own data is pulled
  /// from Firestore during the sign-in merge.
  ///
  /// Returns true if any user-owned table contains at least one row.
  /// Used to detect guest data before a sign-in merge decision.
  static Future<bool> hasUserData() async {
    final Database db = _db!;
    for (final String table in <String>[
      bookmark,
      unknownWords,
      trainingLevelPosition,
      quizResults,
      trainingProgress,
      listenedWords,
      listeningResults,
      recentSearches,
    ]) {
      final List<Map<String, Object?>> result =
          await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
      if ((result.first['c'] as int) > 0) return true;
    }
    return false;
  }

  /// The read-only dictionary tables (DeAz, AzDe) are shared assets and
  /// are intentionally left untouched.
  static Future<void> clearUserData() async {
    final Database db = _db!;
    await db.delete(bookmark);
    await db.delete(unknownWords);
    await db.delete(trainingLevelPosition);
    await db.delete(quizResults);
    await db.delete(trainingProgress);
    await db.delete(listenedWords);
    await db.delete(listeningResults);
    await db.delete(quizResultAnswers);
    await db.delete(listeningResultAnswers);
    await db.delete(recentSearches);
  }
}
