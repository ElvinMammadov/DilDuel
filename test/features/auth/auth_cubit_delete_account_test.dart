import 'package:checks/checks.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/listening_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/quiz_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository(this.events);

  final List<String> events;
  Exception? error;
  String? receivedPassword;

  @override
  bool hasPasswordSignIn = false;

  @override
  Future<void> deleteAccount({String? password}) async {
    events.add('deleteAccount');
    receivedPassword = password;
    final Exception? failure = error;
    if (failure != null) throw failure;
  }
}

class _FakeTrainingRepository extends Fake
    implements TrainingProgressRepository {
  _FakeTrainingRepository(this.events);

  final List<String> events;

  @override
  Future<void> flush() async => events.add('flush');
}

class _FakeBookmarks extends Fake implements BookmarkRepository {}

class _FakeQuizResults extends Fake implements QuizResultRepository {}

class _FakeListeningResults extends Fake implements ListeningResultRepository {}

void main() {
  late List<String> events;
  late _FakeAuthRepository authRepository;
  late AuthCubit cubit;

  setUp(() {
    events = <String>[];
    authRepository = _FakeAuthRepository(events);
    cubit = AuthCubit(
      authRepository,
      _FakeBookmarks(),
      _FakeQuizResults(),
      _FakeTrainingRepository(events),
      _FakeListeningResults(),
    );
  });

  tearDown(() => cubit.close());

  group('deleteAccount', () {
    test('flushes queued progress before deleting, then succeeds', () async {
      final DeleteAccountResult result = await cubit.deleteAccount();

      check(result).equals(DeleteAccountResult.success);
      check(events).deepEquals(<String>['flush', 'deleteAccount']);
    });

    test('passes the password through', () async {
      await cubit.deleteAccount(password: 'secret');

      check(authRepository.receivedPassword).equals('secret');
    });

    test('reports whether a password is needed', () {
      authRepository.hasPasswordSignIn = true;

      check(cubit.deletionNeedsPassword).isTrue();
    });

    test('leaves the signed-in state untouched on failure', () async {
      authRepository.error = Exception('boom');

      await cubit.deleteAccount();

      check(cubit.state).isA<AuthInitial>();
    });

    group('maps errors to results', () {
      final Map<String, (Exception, DeleteAccountResult)> cases =
          <String, (Exception, DeleteAccountResult)>{
        'cancelled provider prompt': (
          const SignInCancelledException(),
          DeleteAccountResult.cancelled,
        ),
        'cancelled Apple sheet': (
          const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.canceled,
            message: '',
          ),
          DeleteAccountResult.cancelled,
        ),
        'other Apple error': (
          const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.failed,
            message: '',
          ),
          DeleteAccountResult.failed,
        ),
        'wrong password': (
          fb.FirebaseAuthException(code: 'wrong-password'),
          DeleteAccountResult.wrongPassword,
        ),
        'invalid credential': (
          fb.FirebaseAuthException(code: 'invalid-credential'),
          DeleteAccountResult.wrongPassword,
        ),
        'no network': (
          fb.FirebaseAuthException(code: 'network-request-failed'),
          DeleteAccountResult.networkError,
        ),
        'recent login required': (
          fb.FirebaseAuthException(code: 'requires-recent-login'),
          DeleteAccountResult.failed,
        ),
        'unexpected error': (Exception('boom'), DeleteAccountResult.failed),
      };

      cases.forEach((String name, (Exception, DeleteAccountResult) testCase) {
        test(name, () async {
          authRepository.error = testCase.$1;

          final DeleteAccountResult result = await cubit.deleteAccount();

          check(result).equals(testCase.$2);
        });
      });
    });
  });
}
