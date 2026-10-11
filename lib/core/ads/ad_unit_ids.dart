import 'dart:io';

import 'package:flutter/foundation.dart';

/// Ad unit IDs for the banner.
///
/// Debug and profile builds always use Google's test unit, so developers never
/// load, or tap, real ads. Release builds use the real unit for the platform;
/// `--dart-define=ADMOB_BANNER_ANDROID=...` / `ADMOB_BANNER_IOS=...` override
/// it.
abstract final class AdUnitIds {
  static const String _androidTestBanner =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _iosTestBanner = 'ca-app-pub-3940256099942544/2435281174';
  static const String _androidBanner = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-5853546703249054/6905276082',
  );
  static const String _iosBanner = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-5853546703249054/8609431335',
  );

  /// The banner ad unit for the current platform and build mode.
  static String get banner {
    final bool ios = Platform.isIOS;
    final String configured = ios ? _iosBanner : _androidBanner;
    if (kReleaseMode && configured.isNotEmpty) return configured;
    return ios ? _iosTestBanner : _androidTestBanner;
  }
}
