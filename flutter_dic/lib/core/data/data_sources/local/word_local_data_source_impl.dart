import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dic/core/data/data_sources/local/word_local_data_source.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
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

  static const String colKey = "key";
  static const String colValue = "value";
  static const String colType = "type";

  static Database? _db;

  static Future<void> initDB() async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(documentsDir.path, dbName);

    final bool exists = await File(dbPath).exists();

    if (!exists) {
      final ByteData data = await rootBundle.load("assets/$dbName");
      final Uint8List bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, version: dbVersion);
  }

  static String getTableName(int dicType) => dicType == 321 ? deAz : azDe;

  static Future<List<String>> getWords(int dicType) async {
    final String tableName = getTableName(dicType);
    final List<Map<String, Object?>> result = await _db!.query(tableName);
    return result
        .map((Map<String, Object?> row) => row[colKey] as String)
        .toList();
  }

  Future<List<Word>> searchWords(String key, String dicType) async {
    print("Searching for $key in $dicType");
    final List<Map<String, Object?>> result = await _db!.query(
      dicType,
      where: "UPPER(key) LIKE ?",
      whereArgs: <Object?>['%${key.toUpperCase()}%'],
    );
    return result.map((Map<String, Object?> row) => Word(
        key: row[colKey] as String,
        value: row[colValue] as String,
        dicType: dicType,
      )).toList();
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
}
