import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryTint,
    required this.accent,
    required this.surface,
    required this.headerBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.chipBg,
    required this.success,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.error,
    required this.errorTint,
    required this.info,
    required this.infoTint,
    required this.shadow,
    required this.shadowStrong,
    required this.shadowMedium,
    required this.shadowSubtle,
    required this.barrier,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryTint;
  final Color accent;
  final Color surface;
  final Color headerBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color chipBg;
  final Color success;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color error;
  final Color errorTint;
  final Color info;
  final Color infoTint;
  final Color shadow;
  final Color shadowStrong;
  final Color shadowMedium;
  final Color shadowSubtle;
  final Color barrier;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryTint,
    Color? accent,
    Color? surface,
    Color? headerBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? chipBg,
    Color? success,
    Color? successTint,
    Color? warning,
    Color? warningTint,
    Color? error,
    Color? errorTint,
    Color? info,
    Color? infoTint,
    Color? shadow,
    Color? shadowStrong,
    Color? shadowMedium,
    Color? shadowSubtle,
    Color? barrier,
  }) =>
      AppColors(
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primaryTint: primaryTint ?? this.primaryTint,
        accent: accent ?? this.accent,
        surface: surface ?? this.surface,
        headerBg: headerBg ?? this.headerBg,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        border: border ?? this.border,
        chipBg: chipBg ?? this.chipBg,
        success: success ?? this.success,
        successTint: successTint ?? this.successTint,
        warning: warning ?? this.warning,
        warningTint: warningTint ?? this.warningTint,
        error: error ?? this.error,
        errorTint: errorTint ?? this.errorTint,
        info: info ?? this.info,
        infoTint: infoTint ?? this.infoTint,
        shadow: shadow ?? this.shadow,
        shadowStrong: shadowStrong ?? this.shadowStrong,
        shadowMedium: shadowMedium ?? this.shadowMedium,
        shadowSubtle: shadowSubtle ?? this.shadowSubtle,
        barrier: barrier ?? this.barrier,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoTint: Color.lerp(infoTint, other.infoTint, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      shadowMedium: Color.lerp(shadowMedium, other.shadowMedium, t)!,
      shadowSubtle: Color.lerp(shadowSubtle, other.shadowSubtle, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
    );
  }
}
