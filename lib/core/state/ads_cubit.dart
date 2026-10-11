import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dic/core/ads/ad_consent.dart';
import 'package:flutter_dic/core/state/ads_state.dart';
import 'package:injectable/injectable.dart';

/// Owns advertising consent and tells the UI where banners may appear.
@singleton
class AdsCubit extends Cubit<AdsState> {
  AdsCubit(this._consent) : super(const AdsState());

  final AdConsent _consent;
  bool _started = false;

  /// Collects consent (showing the form if required) and starts the ads SDK
  /// if allowed. Later calls do nothing.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    _apply(await _consent.gather());
  }

  /// Lets the user change their consent choice.
  Future<void> showPrivacyOptions() async =>
      _apply(await _consent.showPrivacyOptions());

  void setTrainingSessionActive({required bool active}) =>
      emit(state.copyWith(trainingSessionActive: active));

  void setQuizSectionOpen({required bool open}) =>
      emit(state.copyWith(quizSectionOpen: open));

  void _apply(AdConsentResult result) => emit(
    state.copyWith(
      canRequestAds: result.canRequestAds,
      privacyOptionsRequired: result.privacyOptionsRequired,
    ),
  );
}
