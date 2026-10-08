import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_paths.dart';
import 'package:flutter_dic/core/data/models/answer_record.dart';
import 'package:flutter_dic/core/data/repositories/listening_result_repository.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/quiz/domain/models/quiz_result.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class FirestoreListeningResultRepository implements ListeningResultRepository {
  FirestoreListeningResultRepository(this._authRepository)
      : _firestore = FirebaseFirestore.instance;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  String? get _uid => _authRepository.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _results(String uid) =>
      _firestore.collection(
        FirestorePaths.userCollection(uid, FirestorePaths.listeningResults),
      );

  static const String _namespace = '6ba7b811-9dad-11d1-80b4-00c04fd430c9';

  String _docId(QuizResult result) =>
      result.dateTime.toIso8601String().replaceAll(':', '-');

  String _resultId(QuizResult result) =>
      const Uuid().v5(_namespace, _docId(result));

  @override
  Future<void> insertListeningResult(QuizResult result) async {
    final String? uid = _uid;
    if (uid == null) return;
    try {
      await _results(uid).doc(_docId(result)).set(<String, dynamic>{
        'id': _resultId(result),
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'dateTime': result.dateTime.toIso8601String(),
        'answers':
            result.answers.map((AnswerRecord a) => a.toJson()).toList(),
        'takenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Firestore insertListeningResult error: $e',
          name: 'FirestoreListeningResultRepository');
    }
  }

  @override
  Future<List<QuizResult>> getListeningResults() async {
    final String? uid = _uid;
    if (uid == null) return <QuizResult>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _results(uid).orderBy('takenAt', descending: true).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              _fromData(d.data()))
          .toList();
    } catch (e) {
      log('Firestore getListeningResults error: $e',
          name: 'FirestoreListeningResultRepository');
      return <QuizResult>[];
    }
  }

  @override
  Future<Map<String, dynamic>> getListeningStatistics() async =>
      <String, dynamic>{'totalSessions': 0, 'averageScore': '0.0'};

  Future<List<QuizResult>> getAllRemoteResults(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _results(uid).get();
      return snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              _fromData(d.data()))
          .toList();
    } catch (e) {
      log('Firestore getAllListeningRemoteResults error: $e',
          name: 'FirestoreListeningResultRepository');
      return <QuizResult>[];
    }
  }

  QuizResult _fromData(Map<String, dynamic> data) {
    final List<dynamic> rawAnswers =
        data['answers'] as List<dynamic>? ?? <dynamic>[];
    final List<AnswerRecord> answers = rawAnswers
        .map((dynamic a) =>
            AnswerRecord.fromJson(a as Map<String, dynamic>))
        .toList();
    return QuizResult(
      score: data['score'] as int,
      totalQuestions: data['totalQuestions'] as int,
      dateTime: DateTime.parse(data['dateTime'] as String),
      answers: answers,
    );
  }
}
