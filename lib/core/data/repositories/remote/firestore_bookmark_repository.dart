import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dic/core/data/repositories/bookmark_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/search/domain/entities/word.dart';
import 'package:injectable/injectable.dart';

/// Bookmark repository backed by Cloud Firestore.
///
/// Firestore path:
///   `users/{uid}/bookmarks/{key_dicType}`
///   `users/{uid}/unknownWords/{key_dicType}`
///
/// This class should only be called when a user is signed in.
@lazySingleton
class FirestoreBookmarkRepository implements BookmarkRepository {
  FirestoreBookmarkRepository(this._authRepository)
      : _firestore = FirebaseFirestore.instance;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  String? get _uid => _authRepository.currentUser?.uid;

  /// Stable doc-id that survives key case differences.
  String _docId(Word word) =>
      '${word.key.toUpperCase()}_${word.dicType}';

  CollectionReference<Map<String, dynamic>> _bookmarks(String uid) =>
      _firestore.collection('users/$uid/bookmarks');

  CollectionReference<Map<String, dynamic>> _unknownWords(String uid) =>
      _firestore.collection('users/$uid/unknownWords');

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  @override
  Future<void> addBookmark(Word word) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _bookmarks(uid).doc(_docId(word)).set(<String, dynamic>{
        'wordId': word.id,
        'key': word.key,
        'value': word.value,
        'dicType': word.dicType,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Firestore addBookmark error: $e',
          name: 'FirestoreBookmarkRepository');
    }
  }

  @override
  Future<void> removeBookmark(Word word) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _bookmarks(uid).doc(_docId(word)).delete();
    } catch (e) {
      log('Firestore removeBookmark error: $e',
          name: 'FirestoreBookmarkRepository');
    }
  }

  @override
  Future<bool> isBookmarked(Word word) async {
    final String? uid = _uid;
    if (uid == null) return false;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _bookmarks(uid).doc(_docId(word)).get();
      return snap.exists;
    } catch (e) {
      log('Firestore isBookmarked error: $e',
          name: 'FirestoreBookmarkRepository');
      return false;
    }
  }

  @override
  Future<List<String>> getAllBookmarks() async {
    final String? uid = _uid;
    if (uid == null) return <String>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _bookmarks(uid).orderBy('savedAt', descending: true).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              d.data()['key'] as String? ?? '')
          .toList();
    } catch (e) {
      log('Firestore getAllBookmarks error: $e',
          name: 'FirestoreBookmarkRepository');
      return <String>[];
    }
  }

  @override
  Future<Word?> getBookmark(String key) async {
    final String? uid = _uid;
    if (uid == null) return null;
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _bookmarks(uid)
          .where('key', isEqualTo: key.toUpperCase())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return _wordFromData(snap.docs.first.data());
    } catch (e) {
      log('Firestore getBookmark error: $e',
          name: 'FirestoreBookmarkRepository');
      return null;
    }
  }

  // ── Unknown words ─────────────────────────────────────────────────────────

  @override
  Future<void> addUnknownWord(Word word) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _unknownWords(uid).doc(_docId(word)).set(<String, dynamic>{
        'wordId': word.id,
        'key': word.key,
        'value': word.value,
        'dicType': word.dicType,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Firestore addUnknownWord error: $e',
          name: 'FirestoreBookmarkRepository');
    }
  }

  @override
  Future<void> removeUnknownWord(Word word) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _unknownWords(uid).doc(_docId(word)).delete();
    } catch (e) {
      log('Firestore removeUnknownWord error: $e',
          name: 'FirestoreBookmarkRepository');
    }
  }

  @override
  Future<bool> isUnknownWord(Word word) async {
    final String? uid = _uid;
    if (uid == null) return false;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _unknownWords(uid).doc(_docId(word)).get();
      return snap.exists;
    } catch (e) {
      log('Firestore isUnknownWord error: $e',
          name: 'FirestoreBookmarkRepository');
      return false;
    }
  }

  @override
  Future<List<String>> getAllUnknownWords() async {
    final String? uid = _uid;
    if (uid == null) return <String>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _unknownWords(uid).orderBy('savedAt', descending: true).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              d.data()['key'] as String? ?? '')
          .toList();
    } catch (e) {
      log('Firestore getAllUnknownWords error: $e',
          name: 'FirestoreBookmarkRepository');
      return <String>[];
    }
  }

  @override
  Future<Word?> getUnknownWord(String key) async {
    final String? uid = _uid;
    if (uid == null) return null;
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _unknownWords(uid)
              .where('key', isEqualTo: key.toUpperCase())
              .limit(1)
              .get();
      if (snap.docs.isEmpty) return null;
      return _wordFromData(snap.docs.first.data());
    } catch (e) {
      log('Firestore getUnknownWord error: $e',
          name: 'FirestoreBookmarkRepository');
      return null;
    }
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  /// Returns all remote bookmarks as [Word] records.
  Future<List<Word>> getAllRemoteBookmarkWords(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _bookmarks(uid).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              _wordFromData(d.data()))
          .toList();
    } catch (e) {
      log('Firestore getAllRemoteBookmarkWords error: $e',
          name: 'FirestoreBookmarkRepository');
      return <Word>[];
    }
  }

  /// Returns all remote unknown words as [Word] records.
  Future<List<Word>> getAllRemoteUnknownWordRecords(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _unknownWords(uid).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              _wordFromData(d.data()))
          .toList();
    } catch (e) {
      log('Firestore getAllRemoteUnknownWordRecords error: $e',
          name: 'FirestoreBookmarkRepository');
      return <Word>[];
    }
  }

  Word _wordFromData(Map<String, dynamic> data) => Word(
        id: data['wordId'] as String?,
        key: data['key'] as String? ?? '',
        value: data['value'] as String? ?? '',
        dicType: data['dicType'] as String? ?? '',
      );
}
