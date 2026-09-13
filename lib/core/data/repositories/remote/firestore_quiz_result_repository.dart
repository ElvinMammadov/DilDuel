import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dic/core/data/repositories/quiz_result_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';

/// Quiz-result repository backed by Cloud Firestore.
///
/// Firestore path: `users/{uid}/quizResults/{dateTime}`
///
/// The document ID is derived from the quiz's [QuizResult.dateTime] so that
/// results taken on different devices never collide or duplicate each other
/// during a sync merge.
@lazySingleton
class FirestoreQuizResultRepository implements QuizResultRepository {
  FirestoreQuizResultRepository(this._authRepository)
      : _firestore = FirebaseFirestore.instance;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  String? get _uid => _authRepository.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _results(String uid) =>
      _firestore.collection('users/$uid/quizResults');

  /// Stable doc-id derived from the quiz datetime (colons replaced so the
  /// string is safe across all Firestore client versions).
  String _docId(QuizResult result) =>
      result.dateTime.toIso8601String().replaceAll(':', '-');

  @override
  Future<void> insertQuizResult(QuizResult result) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _results(uid).doc(_docId(result)).set(<String, dynamic>{
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'dateTime': result.dateTime.toIso8601String(),
        'takenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Firestore insertQuizResult error: $e',
          name: 'FirestoreQuizResultRepository');
    }
  }

  @override
  Future<List<QuizResult>> getQuizResults() async {
    final String? uid = _uid;
    if (uid == null) return <QuizResult>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _results(uid).orderBy('takenAt', descending: true).get();
      return snap.docs.map((d) => _fromData(d.data())).toList();
    } catch (e) {
      log('Firestore getQuizResults error: $e',
          name: 'FirestoreQuizResultRepository');
      return <QuizResult>[];
    }
  }

  /// Statistics are computed from local SQLite; Firestore returns defaults.
  @override
  Future<Map<String, dynamic>> getQuizStatistics() async =>
      <String, dynamic>{'totalQuizzes': 0, 'averageScore': '0.0'};

  /// Returns all remote results for use in the on-sign-in merge.
  Future<List<QuizResult>> getAllRemoteResults(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _results(uid).get();
      return snap.docs.map((d) => _fromData(d.data())).toList();
    } catch (e) {
      log('Firestore getAllRemoteResults error: $e',
          name: 'FirestoreQuizResultRepository');
      return <QuizResult>[];
    }
  }

  QuizResult _fromData(Map<String, dynamic> data) => QuizResult(
        score: data['score'] as int,
        totalQuestions: data['totalQuestions'] as int,
        dateTime: DateTime.parse(data['dateTime'] as String),
      );
}