import 'package:checks/checks.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser.visibleEmail', () {
    test('returns a normal address', () {
      const AuthUser user = AuthUser(uid: '1', email: 'elvin@example.com');

      check(user.visibleEmail).equals('elvin@example.com');
    });

    test('hides an Apple Hide My Email address', () {
      const AuthUser user = AuthUser(
        uid: '1',
        email: 'abc123xyz@PrivateRelay.AppleID.com',
      );

      check(user.visibleEmail).isNull();
    });

    test('is null when there is no email', () {
      check(const AuthUser(uid: '1').visibleEmail).isNull();
      check(const AuthUser(uid: '1', email: '  ').visibleEmail).isNull();
    });
  });
}
