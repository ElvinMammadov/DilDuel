import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dic/core/ads/ad_unit_ids.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// An anchored adaptive banner that takes no space until an ad has loaded.
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
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    unawaited(_load());
  }

  Future<void> _load() async {
    final int width = MediaQuery.sizeOf(context).width.truncate();
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    final BannerAd ad = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: size,
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
    await ad.load();
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
    return ColoredBox(
      color: AppColors.of(context).surface,
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
