part of '../../settings.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => <Object?>[];
}

class FeedbackIdle extends FeedbackState {
  const FeedbackIdle();
}

class FeedbackSubmitting extends FeedbackState {
  const FeedbackSubmitting();
}

class FeedbackSent extends FeedbackState {
  const FeedbackSent();
}

class FeedbackFailed extends FeedbackState {
  const FeedbackFailed({required this.isNetworkError});

  final bool isNetworkError;

  @override
  List<Object?> get props => <Object?>[isNetworkError];
}
