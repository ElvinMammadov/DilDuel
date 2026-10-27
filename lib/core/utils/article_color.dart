import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';

/// The colour of a German [article], following the usual grammar
/// convention: blue for der, red for die and green for das.
Color articleColor(String? article, AppColors colors, {required bool isDark}) =>
    switch (article?.toLowerCase()) {
      'der' => isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0),
      'die' => colors.error,
      'das' => colors.success,
      _ => colors.textSecondary,
    };

/// The soft background behind an article of [articleColor], or transparent
/// when [article] is not der, die or das.
Color articleTintColor(
  String? article,
  AppColors colors, {
  required bool isDark,
}) => switch (article?.toLowerCase()) {
  'der' ||
  'die' ||
  'das' => articleColor(article, colors, isDark: isDark).withAlpha(28),
  _ => Colors.transparent,
};
