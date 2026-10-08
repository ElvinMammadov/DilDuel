import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dic/core/data/repositories/local/local_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/sync_training_progress_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocal extends Fake implements LocalTrainingProgressRepository {
  final Map<String, int> positions = <String, int>{};

  @override
  Future<int> getLevelPosition(String level) async => positions[level] ?? 0;

  @override
  Future<void> saveLevelPosition(String level, int index) async =>
      positions[level] = index;
}

class _FakeRemote extends Fake implements FirestoreTrainingProgressRepository {
  final Map<String, int> stored = <String, int>{};
  final List<Map<String, int>> batches = <Map<String, int>>[];
  final List<String> batchUids = <String>[];
  bool failBatches = false;

  @override
  Future<Map<String, int>> getAllRemoteProgress(String uid) async =>
      Map<String, int>.of(stored);

  @override
  Future<void> saveLevelPosition(String level, int index) async =>
      stored[level] = index;

  @override
  Future<void> saveLevelPositions(
    String uid,
    Map<String, int> positions,
  ) async {
    if (failBatches) throw Exception('offline');
    batchUids.add(uid);
    batches.add(Map<String, int>.of(positions));
  }
}

class _FakeAuth extends Fake implements AuthRepository {
  @override
  AuthUser? currentUser = const AuthUser(uid: 'user-1');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeLocal local;
  late _FakeRemote remote;
  late _FakeAuth auth;
  late SyncTrainingProgressRepository repository;

  setUp(() {
    local = _FakeLocal();
    remote = _FakeRemote();
    auth = _FakeAuth();
    repository = SyncTrainingProgressRepository(local, remote, auth);
  });

  /// Runs [body] under fake time and lets pending microtasks settle.
  void run(void Function(FakeAsync async) body) => fakeAsync((FakeAsync async) {
        body(async);
        async.flushMicrotasks();
      });

  /// Saves a position and lets the async local write finish, as a caller
  /// awaiting [SyncTrainingProgressRepository.saveLevelPosition] would.
  void save(FakeAsync async, String level, int index) {
    repository.saveLevelPosition(level, index);
    async.flushMicrotasks();
  }

  group('saveLevelPosition', () {
    test('saves locally at once but does not write remotely yet', () {
      run((FakeAsync async) {
        save(async, 'A1', 3);
        async.flushMicrotasks();

        check(local.positions['A1']).equals(3);
        check(remote.batches).isEmpty();
      });
    });

    test('sends only the latest index per level after the debounce', () {
      run((FakeAsync async) {
        save(async, 'A1', 1);
        save(async, 'A1', 2);
        save(async, 'B1', 7);
        async.elapse(SyncTrainingProgressRepository.debounce);
        async.flushMicrotasks();

        check(remote.batches).length.equals(1);
        check(remote.batches.single)
            .deepEquals(<String, int>{'A1': 2, 'B1': 7});
        check(remote.batchUids.single).equals('user-1');
      });
    });

    test('keeps waiting while the user keeps swiping', () {
      run((FakeAsync async) {
        save(async, 'A1', 1);
        async.elapse(const Duration(seconds: 20));
        save(async, 'A1', 2);
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();

        check(remote.batches).isEmpty();
      });
    });

    test('still sends after the max wait during continuous swiping', () {
      run((FakeAsync async) {
        const Duration step = Duration(seconds: 10);
        int index = 0;
        for (Duration t = Duration.zero;
            t < SyncTrainingProgressRepository.maxWait;
            t += step) {
          save(async, 'A1', ++index);
          async.elapse(step);
        }
        async.flushMicrotasks();

        check(remote.batches).isNotEmpty();
        check(remote.batches.first['A1']).isNotNull();
      });
    });

    test('queues nothing for guests', () {
      run((FakeAsync async) {
        auth.currentUser = null;
        save(async, 'A1', 4);
        async.elapse(SyncTrainingProgressRepository.maxWait);

        check(local.positions['A1']).equals(4);
        check(remote.batches).isEmpty();
      });
    });
  });

  group('flush', () {
    test('sends queued positions immediately', () {
      run((FakeAsync async) {
        save(async, 'A2', 5);
        repository.flush();
        async.flushMicrotasks();

        check(remote.batches.single).deepEquals(<String, int>{'A2': 5});
      });
    });

    test('does not resend a position that is already synced', () {
      run((FakeAsync async) {
        save(async, 'A2', 5);
        repository.flush();
        async.flushMicrotasks();
        save(async, 'A2', 5);
        repository.flush();
        async.flushMicrotasks();

        check(remote.batches).length.equals(1);
      });
    });

    test('drops the queue when the user signed out', () {
      run((FakeAsync async) {
        save(async, 'A1', 2);
        auth.currentUser = null;
        repository.flush();
        async.elapse(SyncTrainingProgressRepository.maxWait);

        check(remote.batches).isEmpty();
      });
    });

    test('drops the queue when a different user is signed in', () {
      run((FakeAsync async) {
        save(async, 'A1', 2);
        auth.currentUser = const AuthUser(uid: 'user-2');
        repository.flush();
        async.flushMicrotasks();

        check(remote.batches).isEmpty();
      });
    });

    test('re-queues a failed send and retries later', () {
      run((FakeAsync async) {
        remote.failBatches = true;
        save(async, 'A1', 9);
        repository.flush();
        async.flushMicrotasks();
        check(remote.batches).isEmpty();

        remote.failBatches = false;
        async.elapse(SyncTrainingProgressRepository.debounce);
        async.flushMicrotasks();

        check(remote.batches.single).deepEquals(<String, int>{'A1': 9});
      });
    });

    test('flushes when the app is paused', () {
      run((FakeAsync async) {
        save(async, 'B2', 11);
        repository.didChangeAppLifecycleState(AppLifecycleState.paused);
        async.flushMicrotasks();

        check(remote.batches.single).deepEquals(<String, int>{'B2': 11});
      });
    });
  });

  group('mergeOnSignIn', () {
    test('pulls remote-ahead and pushes local-ahead positions', () {
      run((FakeAsync async) {
        local.positions.addAll(<String, int>{'A1': 10, 'A2': 2});
        remote.stored.addAll(<String, int>{'A1': 4, 'A2': 8});
        repository.mergeOnSignIn('user-1');
        async.flushMicrotasks();

        check(local.positions['A2']).equals(8);
        check(remote.stored['A1']).equals(10);
        check(local.positions['A1']).equals(10);
        check(remote.stored['A2']).equals(8);
      });
    });

    test('does not resend merged positions on the next flush', () {
      run((FakeAsync async) {
        local.positions['B1'] = 6;
        repository.mergeOnSignIn('user-1');
        async.flushMicrotasks();
        save(async, 'B1', 6);
        repository.flush();
        async.flushMicrotasks();

        check(remote.batches).isEmpty();
      });
    });
  });
}
