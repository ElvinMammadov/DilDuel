import 'package:checks/checks.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Word.translationPluralAt', () {
    const Word word = Word(
      key: 'kök',
      value: '1. füllig\n2. die Karotte\n3. die Wurzel',
      dicType: 'AzDe',
      translationPlurals: '1.\n2. die Karotten\n3. die Wurzeln',
    );

    test('returns the plural of the matching translation', () {
      check(word.translationPluralAt(1)).equals('die Karotten');
      check(word.translationPluralAt(2)).equals('die Wurzeln');
    });

    test('is null for a translation without a plural', () {
      check(word.translationPluralAt(0)).isNull();
    });

    test('is null past the last line', () {
      check(word.translationPluralAt(5)).isNull();
    });

    test('is null when the word has no plurals at all', () {
      const Word plain = Word(key: 'a', value: '1. b', dicType: 'AzDe');

      check(plain.translationPluralAt(0)).isNull();
    });

    test('does not mistake 1. for 10.', () {
      const Word many = Word(
        key: 'k',
        value: '1. a\n2. b\n3. c\n4. d\n5. e\n6. f\n7. g\n8. h\n9. i\n10. j',
        dicType: 'AzDe',
        translationPlurals: '1.\n10. die Js',
      );

      check(many.translationPluralAt(0)).isNull();
      check(many.translationPluralAt(9)).equals('die Js');
    });
  });
}
