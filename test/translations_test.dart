import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> _flattenKeys(Map<String, dynamic> json, [String prefix = '']) =>
    <String>{
      for (final MapEntry<String, dynamic> entry in json.entries)
        if (entry.value is Map<String, dynamic>)
          ..._flattenKeys(
              entry.value as Map<String, dynamic>, '$prefix${entry.key}.')
        else
          '$prefix${entry.key}',
    };

Set<String> _keysOf(String locale) => _flattenKeys(
      jsonDecode(File('assets/translations/$locale.json').readAsStringSync())
          as Map<String, dynamic>,
    );

void main() {
  test('az and de define the same translation keys', () {
    final Set<String> az = _keysOf('az');
    final Set<String> de = _keysOf('de');

    check(az.difference(de)).isEmpty();
    check(de.difference(az)).isEmpty();
  });

  test('new delete-account and jump strings exist', () {
    final Set<String> az = _keysOf('az');

    void expectKey(String key) => check(az).contains(key);
    <String>[
      'settings.delete_account.title',
      'settings.delete_account.error_wrong_password',
      'training.jump.title',
      'training.jump.go',
    ].forEach(expectKey);
  });
}
