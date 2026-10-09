import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dic/core/data/models/feedback_submission.dart';
import 'package:flutter_dic/core/data/repositories/feedback_repository.dart';
import 'package:flutter_dic/core/data/repositories/remote/firestore_paths.dart';
import 'package:injectable/injectable.dart';

/// Stores feedback in the top-level Firestore collection `feedback`.
///
/// Guests can send feedback too, so documents carry no user id. The send
/// time comes from the server, not the device clock.
@LazySingleton(as: FeedbackRepository)
class FirestoreFeedbackRepository implements FeedbackRepository {
  FirestoreFeedbackRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// While offline Firestore queues the write and never completes the
  /// future, which would leave the user waiting on a spinner.
  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<void> submit(FeedbackSubmission submission) async {
    try {
      await _firestore
          .collection(FirestorePaths.feedback)
          .add(<String, dynamic>{
        'name': submission.name,
        'message': submission.message,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(_timeout);
    } on TimeoutException {
      throw const FeedbackNetworkException();
    } on FirebaseException catch (error) {
      if (error.code == 'unavailable') throw const FeedbackNetworkException();
      rethrow;
    }
  }
}
