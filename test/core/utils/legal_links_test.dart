import 'package:checks/checks.dart';
import 'package:flutter_dic/core/utils/legal_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String base = 'https://elvinmammadov.github.io/DilDuel/';

  group('LegalLinks', () {
    test('points German and Azerbaijani users to their language', () {
      check(LegalLinks.privacyPolicy('de').toString())
          .equals('${base}de/privacy/');
      check(LegalLinks.privacyPolicy('az').toString())
          .equals('${base}az/privacy/');
      check(LegalLinks.impressum('de').toString())
          .equals('${base}de/impressum/');
      check(LegalLinks.impressum('az').toString())
          .equals('${base}az/impressum/');
    });

    test('falls back to the English pages for other languages', () {
      check(LegalLinks.privacyPolicy('en').toString())
          .equals('${base}privacy/');
      check(LegalLinks.impressum('fr').toString()).equals('${base}impressum/');
    });
  });
}
