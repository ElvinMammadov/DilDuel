import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/bottom_sheet_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light palette ───────────────────────────────────────────
  static const Color mainColor       = Color(0xFF4F3DE0); // deep indigo
  static const Color primaryTint     = Color(0xFFEDEAFB);
  static const Color accentColor     = Color(0xFFB9790C); // warm gold
  static const Color secondaryColor  = Color(0xFF6B6580);

  static const Color backgroundLight = Color(0xFFF6F5FB);
  static const Color headerBgLight   = Color(0xFFEDEAFB);
  static const Color surfaceLight    = Color(0xFFFFFFFF);

  static const Color textPrimaryLight   = Color(0xFF1B1730);
  static const Color textSecondaryLight = Color(0xFF6B6580);

  static const Color borderLight     = Color(0xFFE7E4F3);
  static const Color chipBgLight     = Color(0xFFF0EEF9);

  static const Color successColor    = Color(0xFF1FA97E);
  static const Color successTint     = Color(0xFFE6F6EF);
  static const Color warningColor    = Color(0xFFFFB74D);
  static const Color errorColor      = Color(0xFFD63C41);
  static const Color errorTint       = Color(0xFFFBE9EA);

  // ─── Dark palette ────────────────────────────────────────────
  static const Color mainColorDark      = Color(0xFF8C7DFF);
  static const Color primaryTintDark    = Color(0x2E8C7DFF); // ~18%
  static const Color accentColorDark    = Color(0xFFFBBF57);

  static const Color backgroundDark  = Color(0xFF14121F);
  static const Color headerBgDark    = Color(0xFF1B1830);
  static const Color surfaceDark     = Color(0xFF1E1B2E);

  static const Color textPrimaryDark    = Color(0xFFF3F1FA);
  static const Color textSecondaryDark  = Color(0xFFA39FB8);

  static const Color borderDark      = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  static const Color successColorDark = Color(0xFF4ADE9A);
  static const Color successTintDark  = Color(0x294ADE9A);
  static const Color errorColorDark   = Color(0xFFFF7A7D);
  static const Color errorTintDark    = Color(0x24FF7A7D);

  // ─── Spacing ─────────────────────────────────────────────────
  static const double spacing      = 8.0;
  static const double spacingSmall = spacing / 2;
  static const double spacingLarge = spacing * 2;

  // ─── Border radii ─────────────────────────────────────────────
  static const double borderRadius      = 12.0;
  static const double borderRadiusLarge = 18.0;
  static const double borderRadiusPill  = 100.0;

  // ─── Elevations ───────────────────────────────────────────────
  static const double elevationSmall  = 0.0;
  static const double elevationNormal = 1.0;

  // ─── Typography helpers ───────────────────────────────────────
  static TextStyle get _base => GoogleFonts.plusJakartaSans();
  static TextStyle get _serif => GoogleFonts.sourceSerif4();

  static TextStyle headlineLarge(Color c) =>
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);

  static TextStyle headlineMedium(Color c) =>
      _serif.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: c);

  static TextStyle titleLarge(Color c) =>
      _base.copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: c);

  static TextStyle titleMedium(Color c) =>
      _base.copyWith(fontSize: 17, fontWeight: FontWeight.w700, color: c, letterSpacing: -0.2);

  static TextStyle bodyLarge(Color c) =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: c);

  static TextStyle bodyMedium(Color c) =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: c);

  static TextStyle labelSmall(Color c) =>
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: c);

  // Word source — serif, bold
  static TextStyle wordSource(Color c, {double size = 18}) =>
      _serif.copyWith(fontSize: size, fontWeight: FontWeight.w700, color: c);

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
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        side: const BorderSide(color: borderLight),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineLarge:  headlineLarge(textPrimaryLight),
      headlineMedium: headlineMedium(textPrimaryLight),
      titleLarge:     titleLarge(textPrimaryLight),
      titleMedium:    titleMedium(textPrimaryLight),
      bodyLarge:      bodyLarge(textPrimaryLight),
      bodyMedium:     bodyMedium(textSecondaryLight),
      labelSmall:     labelSmall(textSecondaryLight),
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
        borderRadius: BorderRadius.circular(borderRadiusLarge),
        side: const BorderSide(color: borderDark),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineLarge:  headlineLarge(textPrimaryDark),
      headlineMedium: headlineMedium(textPrimaryDark),
      titleLarge:     titleLarge(textPrimaryDark),
      titleMedium:    titleMedium(textPrimaryDark),
      bodyLarge:      bodyLarge(textPrimaryDark),
      bodyMedium:     bodyMedium(textSecondaryDark),
      labelSmall:     labelSmall(textSecondaryDark),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: mainColorDark,
      linearTrackColor: borderDark,
    ),
    useMaterial3: true,
  );
}