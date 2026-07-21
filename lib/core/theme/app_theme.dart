import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/bottom_sheet_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class AppTheme {
  // ─── Light palette ───────────────────────────────────────────
  static const Color mainColor = Color(0xFF4F3DE0); // deep indigo
  static const Color primaryTint = Color(0xFFEDEAFB);
  static const Color accentColor = Color(0xFFB9790C); // warm gold
  static const Color secondaryColor = Color(0xFF6B6580);

  static const Color backgroundLight = Color(0xFFF6F5FB);
  static const Color headerBgLight = Color(0xFFEDEAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color textPrimaryLight = Color(0xFF1B1730);
  static const Color textSecondaryLight = Color(0xFF6B6580);

  static const Color borderLight = Color(0xFFE7E4F3);
  static const Color chipBgLight = Color(0xFFF0EEF9);

  static const Color successColor = Color(0xFF1FA97E);
  static const Color successTint = Color(0xFFE6F6EF);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color warningTint = Color(0xFFFFF3E0);
  static const Color errorColor = Color(0xFFD63C41);
  static const Color errorTint = Color(0xFFFBE9EA);

  // ─── Dark palette ────────────────────────────────────────────
  static const Color mainColorDark = Color(0xFF8C7DFF);
  static const Color primaryTintDark = Color(0x2E8C7DFF); // ~18%
  static const Color accentColorDark = Color(0xFFFBBF57);

  static const Color backgroundDark = Color(0xFF14121F);
  static const Color headerBgDark = Color(0xFF1B1830);
  static const Color surfaceDark = Color(0xFF1E1B2E);

  static const Color textPrimaryDark = Color(0xFFF3F1FA);
  static const Color textSecondaryDark = Color(0xFFA39FB8);

  static const Color borderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  static const Color successColorDark = Color(0xFF4ADE9A);
  static const Color successTintDark = Color(0x294ADE9A);
  static const Color errorColorDark = Color(0xFFFF7A7D);
  static const Color errorTintDark = Color(0x24FF7A7D);

  // ─── Light Theme ──────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: mainColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: headerBgLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    bottomSheetTheme: const CustomBottomSheetTheme(),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
        side: const BorderSide(color: borderLight),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge(textPrimaryLight),
      headlineMedium: AppTextStyles.headlineMedium(textPrimaryLight),
      titleLarge: AppTextStyles.titleLarge(textPrimaryLight),
      titleMedium: AppTextStyles.titleMedium(textPrimaryLight),
      bodyLarge: AppTextStyles.bodyLarge(textPrimaryLight),
      bodyMedium: AppTextStyles.bodyMedium(textSecondaryLight),
      labelSmall: AppTextStyles.labelSmall(textSecondaryLight),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: mainColor,
      linearTrackColor: borderLight,
    ),
    useMaterial3: true,
  );

  // ─── Dark Theme ───────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: mainColorDark,
      onPrimary: Colors.white,
      secondary: Color(0xFFA39FB8),
      onSecondary: Colors.white,
      error: errorColorDark,
      onError: Colors.white,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: headerBgDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    bottomSheetTheme: const CustomBottomSheetTheme(),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLarge),
        side: const BorderSide(color: borderDark),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge(textPrimaryDark),
      headlineMedium: AppTextStyles.headlineMedium(textPrimaryDark),
      titleLarge: AppTextStyles.titleLarge(textPrimaryDark),
      titleMedium: AppTextStyles.titleMedium(textPrimaryDark),
      bodyLarge: AppTextStyles.bodyLarge(textPrimaryDark),
      bodyMedium: AppTextStyles.bodyMedium(textSecondaryDark),
      labelSmall: AppTextStyles.labelSmall(textSecondaryDark),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: mainColorDark,
      linearTrackColor: borderDark,
    ),
    useMaterial3: true,
  );
}
