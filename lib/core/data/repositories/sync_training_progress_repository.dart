import 'dart:async';
import 'dart:developer';
import 'dart:math' show max;

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
/// batch after [debounce] of inactivity (at most [maxWait] after the first
/// queued change) or on [flush]. Only the latest index per level is sent.
///
/// [mergeOnSignIn] merges both ways, keeping the furthest index per level.
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

  /// Inactivity period after which queued positions are sent.
  static const Duration debounce = Duration(seconds: 30);

  /// Upper bound on how long a queued position waits while the user keeps
  /// swiping.
  static const Duration maxWait = Duration(minutes: 2);

  final LocalTrainingProgressRepository _local;
  final FirestoreTrainingProgressRepository _remote;
  final AuthRepository _authRepository;

  /// Latest unsynced index per level.
  final Map<String, int> _pending = <String, int>{};

  /// Last index known to be on Firestore for the current user, used to skip
  /// redundant writes.
  final Map<String, int> _lastSynced = <String, int>{};

  Timer? _debounceTimer;
  Timer? _maxWaitTimer;
  String? _pendingUid;

  /// Merges remote and local progress, keeping the furthest index per level:
  /// remote-ahead positions are pulled, local-ahead ones (for example guest
  /// progress) are pushed.
  Future<void> mergeOnSignIn(String uid) async {
    _dropPending();
    try {
      final Map<String, int> remote = await _remote.getAllRemoteProgress(uid);
      for (final String level in trainingLevels) {
        await _mergeLevel(level, remote[level] ?? 0);
      }
    } catch (e) {
      log('Training sync merge error: $e',
          name: 'SyncTrainingProgressRepository');
    }
  }

  Future<void> _mergeLevel(String level, int remoteIndex) async {
    final int localIndex = await _local.getLevelPosition(level);
    if (remoteIndex > localIndex) {
      await _local.saveLevelPosition(level, remoteIndex);
    } else if (localIndex > remoteIndex) {
      await _remote.saveLevelPosition(level, localIndex);
    }
    _lastSynced[level] = max(remoteIndex, localIndex);
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, _flushInBackground);
    _maxWaitTimer ??= Timer(maxWait, _flushInBackground);
  }

  void _flushInBackground() => unawaited(flush());

  void _cancelTimers() {
    _debounceTimer?.cancel();
    _maxWaitTimer?.cancel();
    _debounceTimer = null;
    _maxWaitTimer = null;
  }

  void _dropPending() {
    _cancelTimers();
    _pendingUid = null;
    _pending.clear();
    _lastSynced.clear();
  }

  @override
  Future<void> flush() async {
    _cancelTimers();
    if (_pending.isEmpty) return;
    final String? uid = _authRepository.currentUser?.uid;
    if (uid == null || uid != _pendingUid) {
      _dropPending();
      return;
    }
    final Map<String, int> batch = _takePendingBatch();
    if (batch.isNotEmpty) await _send(uid, batch);
  }

  Map<String, int> _takePendingBatch() {
    final Map<String, int> batch = <String, int>{
      for (final MapEntry<String, int> entry in _pending.entries)
        if (_lastSynced[entry.key] != entry.value) entry.key: entry.value,
    };
    _pending.clear();
    return batch;
  }

  Future<void> _send(String uid, Map<String, int> batch) async {
    try {
      await _remote.saveLevelPositions(uid, batch);
      _lastSynced.addAll(batch);
    } catch (e) {
      log('Training remote sync error: $e',
          name: 'SyncTrainingProgressRepository');
      _requeue(batch);
    }
  }

  /// Puts a failed [batch] back in the queue, keeping any newer value saved
  /// while the write was in flight.
  void _requeue(Map<String, int> batch) {
    batch.forEach((String level, int index) {
      _pending.putIfAbsent(level, () => index);
    });
    _scheduleFlush();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _flushInBackground();
    }
  }
}
