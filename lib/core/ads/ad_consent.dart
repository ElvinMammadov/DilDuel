import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:injectable/injectable.dart';

/// Outcome of asking the user for advertising consent.
typedef AdConsentResult = ({bool canRequestAds, bool privacyOptionsRequired});

/// Collects advertising consent and starts the ads SDK once it is allowed.
abstract class AdConsent {
  /// Asks for consent where the law requires it (showing Google's form if
  /// needed), then starts the ads SDK if ads may be requested.
  Future<AdConsentResult> gather();

  /// Shows the form where the user can change an earlier consent choice.
  Future<AdConsentResult> showPrivacyOptions();
}

/// [AdConsent] backed by Google's User Messaging Platform (UMP) and, on iOS,
/// App Tracking Transparency.
@LazySingleton(as: AdConsent)
class GoogleAdConsent implements AdConsent {
  static const AdConsentResult _blocked = (
    canRequestAds: false,
    privacyOptionsRequired: false,
  );

  /// Pretends the device is in the EEA so the consent form can be tested
  /// outside Europe: run a debug build with `--dart-define=ADS_DEBUG_EEA=true`.
  /// Simulators and emulators count as test devices; a physical device must
  /// also be listed in `ConsentDebugSettings.testIdentifiers`.
  static const bool _debugEea = bool.fromEnvironment('ADS_DEBUG_EEA');

  /// Gives the app time to become active; iOS silently skips the tracking
  /// prompt otherwise.
  static const Duration _trackingPromptDelay = Duration(milliseconds: 300);

  @override
  Future<AdConsentResult> gather() async {
    try {
      await _requestInfoUpdate();
      await _showFormIfRequired();
      await _requestTrackingAuthorization();
    } catch (e) {
      // Offline or a failed form: a consent stored earlier may still allow
      // ads, so fall through and read the current status.
      log('Ad consent error: $e', name: 'GoogleAdConsent');
    }
    return _currentStatus();
  }

  @override
  Future<AdConsentResult> showPrivacyOptions() async {
    try {
      await _showPrivacyOptionsForm();
    } catch (e) {
      log('Privacy options error: $e', name: 'GoogleAdConsent');
    }
    return _currentStatus();
  }

  Future<void> _requestInfoUpdate() {
    final Completer<void> completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: kDebugMode && _debugEea
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      ),
      () => completer.complete(),
      (FormError error) => completer.completeError(_formException(error)),
    );
    return completer.future;
  }

  Future<void> _showFormIfRequired() async {
    final Completer<FormError?> completer = Completer<FormError?>();
    await ConsentForm.loadAndShowConsentFormIfRequired(completer.complete);
    final FormError? error = await completer.future;
    if (error != null) throw _formException(error);
  }

  Future<void> _showPrivacyOptionsForm() async {
    final Completer<FormError?> completer = Completer<FormError?>();
    await ConsentForm.showPrivacyOptionsForm(completer.complete);
    final FormError? error = await completer.future;
    if (error != null) throw _formException(error);
  }

  Future<void> _requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status != TrackingStatus.notDetermined) return;
    await Future<void>.delayed(_trackingPromptDelay);
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  Future<AdConsentResult> _currentStatus() async {
    try {
      final bool canRequestAds = await ConsentInformation.instance
          .canRequestAds();
      if (canRequestAds) await MobileAds.instance.initialize();
      final PrivacyOptionsRequirementStatus privacyOptions =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus();
      return (
        canRequestAds: canRequestAds,
        privacyOptionsRequired:
            privacyOptions == PrivacyOptionsRequirementStatus.required,
      );
    } catch (e) {
      log('Ad consent status error: $e', name: 'GoogleAdConsent');
      return _blocked;
    }
  }

  Exception _formException(FormError error) =>
      Exception('${error.errorCode}: ${error.message}');
}
