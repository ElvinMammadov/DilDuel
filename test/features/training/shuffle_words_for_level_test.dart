import 'package:checks/checks.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<Word> words = List<Word>.generate(
    50,
    (int i) => Word(key: 'word$i'),
  );

  List<String?> keys(List<Word> list) =>
      list.map((Word word) => word.key).toList();

  test('returns the same order on every call for a level', () {
    check(
      keys(shuffleWordsForLevel('A1', words)),
    ).deepEquals(keys(shuffleWordsForLevel('A1', words)));
  });

  test('mixes the words instead of keeping the input order', () {
    check(
      keys(shuffleWordsForLevel('A1', words)),
    ).not((Subject<List<String?>> it) => it.deepEquals(keys(words)));
  });

  test('keeps every word exactly once', () {
    final List<String?> shuffled = keys(shuffleWordsForLevel('B2', words));
    check(shuffled.toSet()).deepEquals(keys(words).toSet());
    check(shuffled).length.equals(words.length);
  });

  test('uses a different order for different levels', () {
    check(keys(shuffleWordsForLevel('A1', words))).not(
      (Subject<List<String?>> it) =>
          it.deepEquals(keys(shuffleWordsForLevel('A2', words))),
    );
  });

  test('does not modify the input list', () {
    final List<String?> before = keys(words);
    shuffleWordsForLevel('C1', words);
    check(keys(words)).deepEquals(before);
  });
}
