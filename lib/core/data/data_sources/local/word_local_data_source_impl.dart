import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: WordLocalDataSource)
class DBHelper implements WordLocalDataSource {
  static const String dbName = "luget.db";
  static const int dbVersion = 1;

  static const String deAz = "DeAz";
  static const String azDe = "AzDe";
  static const String bookmark = "bookmark";
  static const String quizResults = "quiz_results";

  static const String colKey = "key";
  static const String colValue = "value";
  static const String colType = "type";

  static Database? _db;

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

  static Future<void> initDB() async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(documentsDir.path, dbName);

    final bool exists = await File(dbPath).exists();

    if (!exists) {
      final ByteData data = await rootBundle.load("assets/$dbName");
      final Uint8List bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(
      dbPath,
      version: dbVersion,
      onCreate: (Database db, int version) async {
        await _createQuizResultsTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await _createQuizResultsTable(db);
        }
      },
      onOpen: (Database db) async {
        // Ensure quiz_results table exists even for existing databases
        await _createQuizResultsTable(db);
      },
    );
  }

  static const int _deAzTypeValue = 321; // matches DictionaryType.deAz.value

  static String getTableName(int dicType) =>
      dicType == _deAzTypeValue ? deAz : azDe;

  static Future<List<String>> getWords(int dicType) async {
    final String tableName = getTableName(dicType);
    final List<Map<String, Object?>> result = await _db!.query(tableName);
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  @override
  Future<List<Word>> searchWords(String key, String dicType) async {
    final String lowerQuery = key.toLowerCase();
    final String query = '''
    SELECT * FROM $dicType
    WHERE LOWER(key) LIKE ? OR LOWER(key) LIKE ?
    ORDER BY 
      CASE 
        WHEN LOWER(key) LIKE ? THEN 1
        WHEN LOWER(key) LIKE ? THEN 2
        ELSE 3
      END,
      key ASC
  ''';

    final List<Map<String, Object?>> result =
        await _db!.rawQuery(query, <Object?>[
      '$lowerQuery%', // WHERE: starts with
      '%$lowerQuery%', // WHERE: contains
      '$lowerQuery%', // ORDER: starts with
      '%$lowerQuery%', // ORDER: contains
    ]);
    return result
        .map((Map<String, Object?> row) => Word(
              key: row[colKey] as String,
              value: row[colValue] as String,
              dicType: dicType,
            ))
        .toList();
  }

  static Future<void> addBookmark(Word word) async {
    await _db!.insert(bookmark, <String, Object?>{
      colKey: word.key,
      colValue: word.value,
      colType: word.dicType,
    });
  }

  static Future<void> removeBookmark(Word word) async {
    await _db!.delete(
      bookmark,
      where: "UPPER(key) = ? AND value = ?",
      whereArgs: <Object?>[word.key.toUpperCase(), word.value],
    );
  }

  static Future<void> removeBookmarkByKey(String key) async {
    await _db!.delete(
      bookmark,
      where: "UPPER(key) = ?",
      whereArgs: <Object?>[key.toUpperCase()],
    );
  }

  static Future<List<String>> getAllBookmarks() async {
    final List<Map<String, Object?>> result =
        await _db!.query(bookmark, orderBy: "date DESC");
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  static Future<bool> isBookmarked(Word word) async {
    final List<Map<String, Object?>> result = await _db!.query(
      bookmark,
      where: "UPPER(key) = ? AND value = ?",
      whereArgs: <Object?>[word.key.toUpperCase(), word.value],
    );
    return result.isNotEmpty;
  }

  static Future<Word?> getBookmark(String key) async {
    final List<Map<String, Object?>> result = await _db!.query(
      bookmark,
      where: "UPPER(key) = ?",
      whereArgs: <Object?>[key.toUpperCase()],
    );
    if (result.isNotEmpty) {
      final Map<String, Object?> row = result.first;
      return Word(
        key: row[colKey] as String,
        value: row[colValue] as String,
        dicType: row[colType] as String,
      );
    }
    return null;
  }

  static Future<void> clearBookmarks() async {
    await _db!.delete(bookmark);
  }

  // Quiz-related methods
  static Future<int> insertQuizResult(QuizResult result) async =>
      await _db!.insert(quizResults, result.toMap());

  static Future<List<QuizResult>> getQuizResults() async {
    final List<Map<String, dynamic>> maps = await _db!.query(
      quizResults,
      orderBy: 'dateTime DESC',
    );
    return List<QuizResult>.generate(
        maps.length, (int i) => QuizResult.fromMap(maps[i]));
  }

  static Future<Map<String, dynamic>> getQuizStatistics() async {
    final List<Map<String, dynamic>> results = await _db!.rawQuery('''
      SELECT 
        COUNT(*) as totalQuizzes,
        AVG(CAST(score AS FLOAT) / CAST(totalQuestions AS FLOAT) * 100) as averageScore
      FROM $quizResults
    ''');

    return <String, dynamic>{
      'totalQuizzes': results[0]['totalQuizzes'] as int,
      'averageScore':
          (results[0]['averageScore'] as double?)?.toStringAsFixed(1) ?? '0.0',
    };
  }
}
