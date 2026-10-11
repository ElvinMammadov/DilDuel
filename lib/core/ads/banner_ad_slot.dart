import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dic/core/ads/ad_unit_ids.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A standard 320x50 banner that takes no space until an ad has loaded.
///
/// The fixed size keeps the banner compact; an adaptive banner grows with the
/// screen width and gets tall on large phones. AdMob does not allow resizing
/// or cropping an ad, so the size can only be changed by picking another
/// [AdSize].
///
/// The loaded ad is kept while [visible] is false, so switching between tabs
/// does not trigger a new ad request every time.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key, required this.visible});

  final bool visible;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final BannerAd ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (Ad failed, LoadAdError error) {
          log('Banner failed to load: $error', name: 'BannerAdSlot');
          failed.dispose();
          if (_ad == failed) _ad = null;
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? ad = _ad;
    if (!widget.visible || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    // The gap keeps the banner clear of buttons above it (such as the
    // training navigation) and of the tab bar below, to avoid accidental taps.
    return ColoredBox(
      color: AppColors.of(context).surface,
      child: Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.padding16,
          bottom: Dimensions.padding8,
        ),
        child: Center(
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}
