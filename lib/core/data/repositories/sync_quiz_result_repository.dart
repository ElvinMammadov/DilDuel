import 'dart:async';
import 'dart:developer';

import 'package:flutter_dic/core/data/repositories/local/local_quiz_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/quiz_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_quiz_result_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';

/// Composite quiz-result repository.
///
/// **Reads** always come from local SQLite — fast and offline-capable.
/// **Writes** go to SQLite immediately; Firestore is updated in the
/// background whenever the user is signed in.
///
/// On sign-in, performs a bidirectional merge:
/// - Remote results missing locally are pulled into SQLite.
/// - Local results missing in Firestore are pushed to the cloud.
@LazySingleton(as: QuizResultRepository)
class SyncQuizResultRepository implements QuizResultRepository {
  SyncQuizResultRepository(
    this._local,
    this._remote,
    this._authRepository,
  ) {
    _authSub = _authRepository.authStateChanges.listen(_onAuthChanged);
  }

  final LocalQuizResultRepository _local;
  final FirestoreQuizResultRepository _remote;
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authSub;

  bool get _isSignedIn => _authRepository.currentUser != null;

  void _onAuthChanged(AuthUser? user) {
    if (user != null) {
      unawaited(_mergeOnSignIn(user.uid));
    }
  }

  Future<void> _mergeOnSignIn(String uid) async {
    try {
      final List<QuizResult> remoteResults =
          await _remote.getAllRemoteResults(uid);
      final List<QuizResult> localResults = await _local.getQuizResults();

      final Set<String> localKeys = localResults
          .map((r) => r.dateTime.toIso8601String())
          .toSet();
      final Set<String> remoteKeys = remoteResults
          .map((r) => r.dateTime.toIso8601String())
          .toSet();

      // Pull remote results that are missing locally.
      for (final QuizResult result in remoteResults) {
        if (!localKeys.contains(result.dateTime.toIso8601String())) {
          await _local.insertQuizResult(result);
        }
      }

      // Push local results that are missing in Firestore.
      for (final QuizResult result in localResults) {
        if (!remoteKeys.contains(result.dateTime.toIso8601String())) {
          await _remote.insertQuizResult(result);
        }
      }
    } catch (e) {
      log('QuizResult sync merge error: $e',
          name: 'SyncQuizResultRepository');
    }
  }

  void _syncRemote(Future<void> Function() action) {
    if (!_isSignedIn) return;
    unawaited(action().catchError((Object e) {
      log('Quiz remote sync error: $e', name: 'SyncQuizResultRepository');
    }));
  }

  @override
  Future<void> insertQuizResult(QuizResult result) async {
    await _local.insertQuizResult(result);
    _syncRemote(() => _remote.insertQuizResult(result));
  }

  @override
  Future<List<QuizResult>> getQuizResults() => _local.getQuizResults();

  /// Statistics are always computed from local SQLite.
  @override
  Future<Map<String, dynamic>> getQuizStatistics() =>
      _local.getQuizStatistics();

  void dispose() => _authSub.cancel();
}
