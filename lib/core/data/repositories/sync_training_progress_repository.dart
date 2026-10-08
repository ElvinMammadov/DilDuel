import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_dic/core/data/repositories/local/local_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_training_progress_repository.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:injectable/injectable.dart';

/// Composite training-progress repository.
///
/// Reads come from local SQLite. Writes go to SQLite immediately, while
/// Firestore writes are coalesced: positions are queued and sent in one
/// batch after [_debounce] of inactivity (at most [_maxWait] after the
/// first queued change) or on [flush]. Only the latest index per level is
/// sent. [mergeOnSignIn] merges remote progress
/// into local (remote wins for higher index values, preserving the
/// furthest-reached position across devices).
///
/// It is called by [AuthCubit], which awaits it before emitting
/// [AuthAuthenticated] so UI state reloads without racing the merge.
@LazySingleton(as: TrainingProgressRepository)
class SyncTrainingProgressRepository
    with WidgetsBindingObserver
    implements TrainingProgressRepository {
  SyncTrainingProgressRepository(
    this._local,
    this._remote,
    this._authRepository,
  ) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration _debounce = Duration(seconds: 30);
  static const Duration _maxWait = Duration(minutes: 2);

  final LocalTrainingProgressRepository _local;
  final FirestoreTrainingProgressRepository _remote;
  final AuthRepository _authRepository;

  /// Latest unsynced index per level.
  final Map<String, int> _pending = <String, int>{};

  /// Last index known to be on Firestore for the current user, used to skip
  /// redundant writes.
  final Map<String, int> _lastSynced = <String, int>{};

  Timer? _timer;
  DateTime? _firstPendingAt;
  String? _pendingUid;

  static const List<String> _levels = <String>['A1', 'A2', 'B1', 'B2'];

  /// Bidirectional merge on sign-in: for each level, keep the furthest
  /// (maximum) index. Remote-ahead positions are pulled to local; local-ahead
  /// positions (e.g. guest progress) are pushed to Firestore.
  Future<void> mergeOnSignIn(String uid) async {
    _dropPending();
    try {
      final Map<String, int> remote = await _remote.getAllRemoteProgress(uid);
      for (final String level in _levels) {
        final int localIndex = await _local.getLevelPosition(level);
        final int remoteIndex = remote[level] ?? 0;
        if (remoteIndex > localIndex) {
          await _local.saveLevelPosition(level, remoteIndex);
        } else if (localIndex > remoteIndex) {
          await _remote.saveLevelPosition(level, localIndex);
        }
        _lastSynced[level] =
            remoteIndex > localIndex ? remoteIndex : localIndex;
      }
    } catch (e) {
      log('Training sync merge error: $e',
          name: 'SyncTrainingProgressRepository');
    }
  }

  void _dropPending() {
    _timer?.cancel();
    _timer = null;
    _firstPendingAt = null;
    _pendingUid = null;
    _pending.clear();
    _lastSynced.clear();
  }

  void _enqueue(String level, int index) {
    final String? uid = _authRepository.currentUser?.uid;
    if (uid == null) return;
    if (_pendingUid != null && _pendingUid != uid) _dropPending();
    _pendingUid = uid;
    if (_pending[level] == null && _lastSynced[level] == index) return;
    _pending[level] = index;
    _scheduleFlush();
  }

  void _scheduleFlush() {
    final DateTime now = DateTime.now();
    final DateTime firstAt = _firstPendingAt ??= now;
    final Duration untilMaxWait = _maxWait - now.difference(firstAt);
    _timer?.cancel();
    _timer = Timer(
      untilMaxWait < _debounce ? untilMaxWait : _debounce,
      () => unawaited(flush()),
    );
  }

  @override
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    _firstPendingAt = null;
    if (_pending.isEmpty) return;
    final String? uid = _authRepository.currentUser?.uid;
    if (uid == null || uid != _pendingUid) {
      _dropPending();
      return;
    }
    final Map<String, int> batch = <String, int>{
      for (final MapEntry<String, int> e in _pending.entries)
        if (_lastSynced[e.key] != e.value) e.key: e.value,
    };
    _pending.clear();
    if (batch.isEmpty) return;
    try {
      await _remote.saveLevelPositions(uid, batch);
      _lastSynced.addAll(batch);
    } catch (e) {
      log('Training remote sync error: $e',
          name: 'SyncTrainingProgressRepository');
      // Re-queue, keeping any newer value saved while the write was in flight.
      batch.forEach((String level, int index) {
        _pending.putIfAbsent(level, () => index);
      });
      _scheduleFlush();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(flush());
    }
  }

  @override
  Future<int> getLevelPosition(String level) => _local.getLevelPosition(level);

  @override
  Future<void> saveLevelPosition(String level, int index) async {
    await _local.saveLevelPosition(level, index);
    _enqueue(level, index);
  }

  @override
  Future<String?> getLastTrainingLevel() => _local.getLastTrainingLevel();
}
