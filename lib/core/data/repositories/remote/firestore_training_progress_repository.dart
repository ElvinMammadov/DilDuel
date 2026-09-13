import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dic/core/data/repositories/training_progress_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:injectable/injectable.dart';

/// Training-progress repository backed by Cloud Firestore.
///
/// Firestore path: `users/{uid}/trainingProgress/{level}`
@lazySingleton
class FirestoreTrainingProgressRepository
    implements TrainingProgressRepository {
  FirestoreTrainingProgressRepository(this._authRepository)
      : _firestore = FirebaseFirestore.instance;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  String? get _uid => _authRepository.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _progress(String uid) =>
      _firestore.collection('users/$uid/trainingProgress');

  @override
  Future<int> getLevelPosition(String level) async {
    final String? uid = _uid;
    if (uid == null) return 0;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _progress(uid).doc(level).get();
      if (!snap.exists) return 0;
      return snap.data()?['currentIndex'] as int? ?? 0;
    } catch (e) {
      log('Firestore getLevelPosition error: $e',
          name: 'FirestoreTrainingProgressRepository');
      return 0;
    }
  }

  @override
  Future<void> saveLevelPosition(String level, int index) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _progress(uid).doc(level).set(
        <String, dynamic>{
          'currentIndex': index,
          'lastAccessedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      log('Firestore saveLevelPosition error: $e',
          name: 'FirestoreTrainingProgressRepository');
    }
  }

  @override
  Future<String?> getLastTrainingLevel() async {
    final String? uid = _uid;
    if (uid == null) return null;
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _progress(uid)
          .orderBy('lastAccessedAt', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.id;
    } catch (e) {
      log('Firestore getLastTrainingLevel error: $e',
          name: 'FirestoreTrainingProgressRepository');
      return null;
    }
  }

  /// Returns all remote progress records as `{level: currentIndex}`.
  Future<Map<String, int>> getAllRemoteProgress(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _progress(uid).get();
      return <String, int>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snap.docs)
          doc.id: doc.data()['currentIndex'] as int? ?? 0,
      };
    } catch (e) {
      log('Firestore getAllRemoteProgress error: $e',
          name: 'FirestoreTrainingProgressRepository');
      return <String, int>{};
    }
  }
}
