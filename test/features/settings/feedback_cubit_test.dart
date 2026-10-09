import 'package:checks/checks.dart';
import 'package:flutter_dic/core/data/models/feedback_submission.dart';
import 'package:flutter_dic/core/data/repositories/feedback_repository.dart';
import 'package:flutter_dic/features/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFeedbackRepository implements FeedbackRepository {
  final List<FeedbackSubmission> submissions = <FeedbackSubmission>[];
  Exception? error;

  @override
  Future<void> submit(FeedbackSubmission submission) async {
    final Exception? failure = error;
    if (failure != null) throw failure;
    submissions.add(submission);
  }
}

void main() {
  late _FakeFeedbackRepository repository;
  late FeedbackCubit cubit;

  setUp(() {
    repository = _FakeFeedbackRepository();
    cubit = FeedbackCubit(repository);
  });

  tearDown(() => cubit.close());

  test('submit sends trimmed text and ends in the sent state', () async {
    final List<FeedbackState> states = <FeedbackState>[];
    cubit.stream.listen(states.add);

    await cubit.submit(name: '  Elvin ', message: ' "Haus" is mistranslated\n');

    check(repository.submissions).length.equals(1);
    check(repository.submissions.single.name).equals('Elvin');
    check(repository.submissions.single.message)
        .equals('"Haus" is mistranslated');
    await Future<void>.delayed(Duration.zero);
    check(states).deepEquals(const <FeedbackState>[
      FeedbackSubmitting(),
      FeedbackSent(),
    ]);
  });

  test('submit reports failure so the user can retry', () async {
    repository.error = Exception('offline');

    await cubit.submit(name: 'Elvin', message: 'Typo');

    check(cubit.state).equals(const FeedbackFailed(isNetworkError: false));
    check(repository.submissions).isEmpty();

    repository.error = null;
    await cubit.submit(name: 'Elvin', message: 'Typo');

    check(cubit.state).isA<FeedbackSent>();
    check(repository.submissions).length.equals(1);
  });

  test('an unreachable server is reported as a network error', () async {
    repository.error = const FeedbackNetworkException();

    await cubit.submit(name: 'Elvin', message: 'Typo');

    check(cubit.state).equals(const FeedbackFailed(isNetworkError: true));
  });

  test('closing while sending does not throw', () async {
    final Future<void> pending = cubit.submit(name: 'Elvin', message: 'Typo');
    await cubit.close();

    await pending;

    check(repository.submissions).length.equals(1);
  });
}
