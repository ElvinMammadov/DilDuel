import 'package:flutter_dic/core/data/models/feedback_submission.dart';

/// Feedback could not be delivered because the server was unreachable.
class FeedbackNetworkException implements Exception {
  const FeedbackNetworkException();
}

abstract class FeedbackRepository {
  /// Delivers [submission] together with the time it was sent.
  ///
  /// Throws [FeedbackNetworkException] when the server was unreachable, and
  /// another exception for any other failure, so the caller can let the user
  /// retry.
  Future<void> submit(FeedbackSubmission submission);
}
