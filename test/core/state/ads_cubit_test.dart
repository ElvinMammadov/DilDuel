import 'package:checks/checks.dart';
import 'package:flutter_dic/core/ads/ad_consent.dart';
import 'package:flutter_dic/core/state/ads_cubit.dart';
import 'package:flutter_dic/core/state/ads_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdConsent implements AdConsent {
  AdConsentResult onGather = (
    canRequestAds: true,
    privacyOptionsRequired: true,
  );
  AdConsentResult onPrivacyOptions = (
    canRequestAds: false,
    privacyOptionsRequired: true,
  );
  int gatherCalls = 0;

  @override
  Future<AdConsentResult> gather() async {
    gatherCalls++;
    return onGather;
  }

  @override
  Future<AdConsentResult> showPrivacyOptions() async => onPrivacyOptions;
}

void main() {
  late _FakeAdConsent consent;
  late AdsCubit cubit;

  setUp(() {
    consent = _FakeAdConsent();
    cubit = AdsCubit(consent);
  });

  tearDown(() => cubit.close());

  test('shows no ads before consent has been gathered', () {
    check(cubit.state.canRequestAds).isFalse();
    check(cubit.state.privacyOptionsRequired).isFalse();
  });

  test('init publishes the consent result', () async {
    await cubit.init();

    check(cubit.state.canRequestAds).isTrue();
    check(cubit.state.privacyOptionsRequired).isTrue();
  });

  test('init asks for consent only once', () async {
    await cubit.init();
    await cubit.init();

    check(consent.gatherCalls).equals(1);
  });

  test('a user who declines gets no ads', () async {
    consent.onGather = (canRequestAds: false, privacyOptionsRequired: true);

    await cubit.init();

    check(cubit.state.canRequestAds).isFalse();
    check(cubit.state.privacyOptionsRequired).isTrue();
  });

  test('changing the choice in privacy options updates the state', () async {
    await cubit.init();

    await cubit.showPrivacyOptions();

    check(cubit.state.canRequestAds).isFalse();
  });

  test('training and quiz flags are independent of consent', () async {
    await cubit.init();

    cubit.setTrainingSessionActive(active: true);
    cubit.setQuizSectionOpen(open: true);

    check(cubit.state).equals(const AdsState(
      canRequestAds: true,
      privacyOptionsRequired: true,
      trainingSessionActive: true,
      quizSectionOpen: true,
    ));

    cubit.setTrainingSessionActive(active: false);

    check(cubit.state.trainingSessionActive).isFalse();
    check(cubit.state.quizSectionOpen).isTrue();
  });

  test('consent results do not reset the session flags', () async {
    cubit.setQuizSectionOpen(open: true);

    await cubit.init();

    check(cubit.state.quizSectionOpen).isTrue();
  });
}
