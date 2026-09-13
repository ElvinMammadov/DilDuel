import 'dart:async';
import 'dart:developer';

import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/local/local_bookmark_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_bookmark_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';

/// Composite bookmark repository.
///
/// **Reads** always come from local SQLite — fast and offline-capable.
/// **Writes** go to local SQLite immediately; Firestore is updated in the
/// background (non-blocking) whenever the user is signed in.
///
/// On sign-in, performs a bidirectional merge so bookmarks from other devices
/// appear locally and any locally-saved items are pushed to the cloud.
@LazySingleton(as: BookmarkRepository)
class SyncBookmarkRepository implements BookmarkRepository {
  SyncBookmarkRepository(
    this._local,
    this._remote,
    this._authRepository,
  ) {
    _authSub = _authRepository.authStateChanges.listen(_onAuthChanged);
  }

  final LocalBookmarkRepository _local;
  final FirestoreBookmarkRepository _remote;
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authSub;

  bool get _isSignedIn => _authRepository.currentUser != null;

  // ── Auth listener ─────────────────────────────────────────────────────────

  void _onAuthChanged(AuthUser? user) {
    if (user != null) {
      // Non-blocking merge: don't await so the listener returns quickly.
      unawaited(_mergeOnSignIn(user.uid));
    }
  }

  /// Bidirectional merge called once per sign-in.
  ///
  /// 1. Pull remote items that are missing locally.
  /// 2. Push local items that are missing in Firestore.
  Future<void> _mergeOnSignIn(String uid) async {
    try {
      await _pullRemoteToLocal(uid);
      await _pushLocalToRemote();
    } catch (e) {
      log('Sync merge error: $e', name: 'SyncBookmarkRepository');
    }
  }

  Future<void> _pullRemoteToLocal(String uid) async {
    final List<Word> remoteBookmarks =
        await _remote.getAllRemoteBookmarkWords(uid);
    for (final Word word in remoteBookmarks) {
      if (!await _local.isBookmarked(word)) {
        await _local.addBookmark(word);
      }
    }

    final List<Word> remoteUnknown =
        await _remote.getAllRemoteUnknownWordRecords(uid);
    for (final Word word in remoteUnknown) {
      if (!await _local.isUnknownWord(word)) {
        await _local.addUnknownWord(word);
      }
    }
  }

  Future<void> _pushLocalToRemote() async {
    final List<Word> localBookmarks = await _local.getAllBookmarkWords();
    for (final Word word in localBookmarks) {
      await _remote.addBookmark(word);
    }

    final List<Word> localUnknown = await _local.getAllUnknownWordRecords();
    for (final Word word in localUnknown) {
      await _remote.addUnknownWord(word);
    }
  }

  /// Fires a remote write without blocking the caller.
  void _syncRemote(Future<void> Function() action) {
    if (!_isSignedIn) return;
    unawaited(action().catchError((Object e) {
      log('Remote sync error: $e', name: 'SyncBookmarkRepository');
    }));
  }

  // ── BookmarkRepository ────────────────────────────────────────────────────

  @override
  Future<void> addBookmark(Word word) async {
    await _local.addBookmark(word);
    _syncRemote(() => _remote.addBookmark(word));
  }

  @override
  Future<void> removeBookmark(Word word) async {
    await _local.removeBookmark(word);
    _syncRemote(() => _remote.removeBookmark(word));
  }

  @override
  Future<bool> isBookmarked(Word word) => _local.isBookmarked(word);

  @override
  Future<List<String>> getAllBookmarks() => _local.getAllBookmarks();

  @override
  Future<Word?> getBookmark(String key) => _local.getBookmark(key);

  @override
  Future<void> addUnknownWord(Word word) async {
    await _local.addUnknownWord(word);
    _syncRemote(() => _remote.addUnknownWord(word));
  }

  @override
  Future<void> removeUnknownWord(Word word) async {
    await _local.removeUnknownWord(word);
    _syncRemote(() => _remote.removeUnknownWord(word));
  }

  @override
  Future<bool> isUnknownWord(Word word) => _local.isUnknownWord(word);

  @override
  Future<List<String>> getAllUnknownWords() => _local.getAllUnknownWords();

  @override
  Future<Word?> getUnknownWord(String key) => _local.getUnknownWord(key);

  void dispose() => _authSub.cancel();
}
