part of '../../settings.dart';

@injectable
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(this._repository) : super(const FeedbackIdle());

  final FeedbackRepository _repository;

  Future<void> submit({required String name, required String message}) async {
    if (state is FeedbackSubmitting) return;
    emit(const FeedbackSubmitting());
    try {
      await _repository.submit(
        FeedbackSubmission(name: name.trim(), message: message.trim()),
      );
      if (!isClosed) emit(const FeedbackSent());
    } catch (error) {
      log('Submitting feedback failed: $error', name: 'FeedbackCubit');
      if (!isClosed) {
        emit(FeedbackFailed(isNetworkError: error is FeedbackNetworkException));
      }
    }
  }
}
