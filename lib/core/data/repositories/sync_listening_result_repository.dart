import 'dart:async';
import 'dart:developer';

import 'package:flutter_dic/core/data/repositories/listening_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/local/local_listening_result_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_listening_result_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ListeningResultRepository)
class SyncListeningResultRepository implements ListeningResultRepository {
  SyncListeningResultRepository(
    this._local,
    this._remote,
    this._authRepository,
  );

  final LocalListeningResultRepository _local;
  final FirestoreListeningResultRepository _remote;
  final AuthRepository _authRepository;

  bool get _isSignedIn => _authRepository.currentUser != null;

  Future<void> mergeOnSignIn(String uid) async {
    try {
      final List<QuizResult> remoteResults =
          await _remote.getAllRemoteResults(uid);
      final List<QuizResult> localResults = await _local.getListeningResults();

      final Set<String> localKeys = localResults
          .map((QuizResult r) => r.dateTime.toIso8601String())
          .toSet();
      final Set<String> remoteKeys = remoteResults
          .map((QuizResult r) => r.dateTime.toIso8601String())
          .toSet();

      for (final QuizResult result in remoteResults) {
        if (!localKeys.contains(result.dateTime.toIso8601String())) {
          await _local.insertListeningResult(result);
        }
      }

      for (final QuizResult result in localResults) {
        if (!remoteKeys.contains(result.dateTime.toIso8601String())) {
          await _remote.insertListeningResult(result);
        }
      }
    } catch (e) {
      log('ListeningResult sync merge error: $e',
          name: 'SyncListeningResultRepository');
    }
  }

  void _syncRemote(Future<void> Function() action) {
    if (!_isSignedIn) return;
    unawaited(action().catchError((Object e) {
      log('Listening remote sync error: $e',
          name: 'SyncListeningResultRepository');
    }));
  }

  @override
  Future<void> insertListeningResult(QuizResult result) async {
    await _local.insertListeningResult(result);
    _syncRemote(() => _remote.insertListeningResult(result));
  }

  @override
  Future<List<QuizResult>> getListeningResults() =>
      _local.getListeningResults();

  @override
  Future<Map<String, dynamic>> getListeningStatistics() =>
      _local.getListeningStatistics();
}
