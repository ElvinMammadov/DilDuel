import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Map<String, List<String>> topicIds;

  setUp(() {
    final Map<String, dynamic> json =
        jsonDecode(File('assets/training_topics.json').readAsStringSync())
            as Map<String, dynamic>;
    topicIds = <String, List<String>>{
      for (final MapEntry<String, dynamic> entry in json.entries)
        entry.key: List<String>.from(entry.value as List<dynamic>),
    };
  });

  test('defines a word list for every training topic, in order', () {
    check(topicIds.keys.toList()).deepEquals(trainingTopics);
  });

  test('every topic has words', () {
    for (final MapEntry<String, List<String>> entry in topicIds.entries) {
      check(because: entry.key, entry.value).isNotEmpty();
    }
  });

  test('no word belongs to two topics or appears twice', () {
    final List<String> all = <String>[
      for (final List<String> ids in topicIds.values) ...ids,
    ];
    check(all.toSet()).length.equals(all.length);
  });

  test('every id exists in the bundled dictionary', () async {
    final Database db = await databaseFactoryFfi.openDatabase(
      File('assets/luget.db').absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    addTearDown(db.close);
    final List<Map<String, Object?>> rows = await db.query(
      'DeAz',
      columns: <String>['id'],
    );
    final Set<String> known = <String>{
      for (final Map<String, Object?> row in rows) row['id']! as String,
    };

    final Set<String> missing = <String>{
      for (final List<String> ids in topicIds.values) ...ids,
    }.difference(known);
    check(missing).isEmpty();
  });

  test('topic deck keys round-trip and differ from level keys', () {
    check(isTopicDeck(topicDeck('animals'))).isTrue();
    check(topicOfDeck(topicDeck('animals'))).equals('animals');
    for (final String level in trainingLevels) {
      check(isTopicDeck(level)).isFalse();
    }
    check(
      trainingDecks,
    ).length.equals(trainingLevels.length + trainingTopics.length);
  });
}
