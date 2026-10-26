import 'package:checks/checks.dart';
import 'package:flutter_dic/core/utils/bare_word.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Word word(String key, {String? article, String dicType = 'DeAz'}) =>
      Word(key: key, value: '', dicType: dicType, article: article);

  group('bareWord', () {
    test('strips the stored article', () {
      check(bareWord(word('das Haus', article: 'das'))).equals('Haus');
    });

    test('strips der, die and das when the article is unknown', () {
      check(bareWord(word('der Mann'))).equals('Mann');
      check(bareWord(word('die Frau'))).equals('Frau');
      check(bareWord(word('das Einfamilienhaus'))).equals('Einfamilienhaus');
    });

    test('leaves words without an article alone', () {
      check(bareWord(word('haushalten'))).equals('haushalten');
      check(bareWord(word('dasselbe'))).equals('dasselbe');
    });

    test('does not touch Azerbaijani keys', () {
      check(
        bareWord(word('die ev', dicType: 'AzDe')),
      ).equals('die ev');
    });
  });
}
