import 'dart:async';
import 'dart:developer';

import 'package:flutter_dic/core/data/repositories/local/local_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:injectable/injectable.dart';

/// Composite training-progress repository.
///
/// Reads come from local SQLite. Writes go to SQLite immediately and
/// Firestore in the background. [mergeOnSignIn] merges remote progress
/// into local (remote wins for higher index values, preserving the
/// furthest-reached position across devices).
///
/// It is called by [AuthCubit], which awaits it before emitting
/// [AuthAuthenticated] so UI state reloads without racing the merge.
@LazySingleton(as: TrainingProgressRepository)
class SyncTrainingProgressRepository implements TrainingProgressRepository {
  SyncTrainingProgressRepository(
    this._local,
    this._remote,
    this._authRepository,
  );

  final LocalTrainingProgressRepository _local;
  final FirestoreTrainingProgressRepository _remote;
  final AuthRepository _authRepository;

  bool get _isSignedIn => _authRepository.currentUser != null;

  /// On sign-in: pull remote positions and keep the maximum (furthest)
  /// index per level so no progress is lost across devices.
  Future<void> mergeOnSignIn(String uid) async {
    try {
      final Map<String, int> remote = await _remote.getAllRemoteProgress(uid);
      for (final MapEntry<String, int> entry in remote.entries) {
        final int localIndex = await _local.getLevelPosition(entry.key);
        if (entry.value > localIndex) {
          await _local.saveLevelPosition(entry.key, entry.value);
        }
      }
    } catch (e) {
      log('Training sync merge error: $e',
          name: 'SyncTrainingProgressRepository');
    }
  }

  void _syncRemote(Future<void> Function() action) {
    if (!_isSignedIn) return;
    unawaited(action().catchError((Object e) {
      log('Training remote sync error: $e',
          name: 'SyncTrainingProgressRepository');
    }));
  }

  @override
  Future<int> getLevelPosition(String level) => _local.getLevelPosition(level);

  @override
  Future<void> saveLevelPosition(String level, int index) async {
    await _local.saveLevelPosition(level, index);
    _syncRemote(() => _remote.saveLevelPosition(level, index));
  }

  @override
  Future<String?> getLastTrainingLevel() => _local.getLastTrainingLevel();
}
