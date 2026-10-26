import 'package:checks/checks.dart';
import 'package:flutter_dic/core/utils/grammar_type_translator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gender labels', () {
    test('stored English values become German grammar terms', () {
      check(GrammarTypeTranslator.germanGender('Masculine')).equals('Maskulin');
      check(GrammarTypeTranslator.germanGender('Feminine')).equals('Feminin');
      check(GrammarTypeTranslator.germanGender('Neuter')).equals('Neutrum');
    });

    test('unknown values are returned unchanged', () {
      check(GrammarTypeTranslator.germanGender('Plural')).equals('Plural');
    });

    test('the Azerbaijani gloss names the gender, not a person', () {
      check(GrammarTypeTranslator.gender('Masculine')).equals('kişi cinsi');
      check(GrammarTypeTranslator.gender('Feminine')).equals('qadın cinsi');
      check(GrammarTypeTranslator.gender('Neuter')).equals('orta cins');
    });
  });
}
