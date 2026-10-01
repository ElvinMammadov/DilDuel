import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_text_styles.dart';
import 'package:flutter_dic/core/theme/bottom_sheet_theme.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';

class AppTheme {
  // ─── Light palette ───────────────────────────────────────────
  static const Color mainColor = Color(0xFF4F3DE0); // deep indigo
  static const Color primaryTint = Color(0xFFEDEAFB);
  static const Color levelA1 = Color(0xFF7B6CF0);
  static const Color levelA2 = Color(0xFF6252E6);
  static const Color levelB1 = Color(0xFF4F3DE0);
  static const Color levelB2 = Color(0xFF3626A8);
  static const Color bookmarksCard = Color(0xFFB9790C);
  static const Color unknownCard = Color(0xFF8F5A00);
  static const Color quizCard = Color(0xFF1FA97E);
  static const Color listeningCard = Color(0xFF138A6F);
  static const Color resultsCard = Color(0xFF0C6B58);
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
  static const Color warningColor = Color(0xFFB96400);
  static const Color warningTint = Color(0xFFFFF3E0);
  static const Color errorColor = Color(0xFFD63C41);
  static const Color errorTint = Color(0xFFFBE9EA);

  // ─── Dark palette ────────────────────────────────────────────
  static const Color mainColorDark = Color(0xFF8C7DFF);
  static const Color primaryTintDark = Color(0x2E8C7DFF); // ~18%
  static const Color levelA1Dark = Color(0xFF8C7DFF);
  static const Color levelA2Dark = Color(0xFF7767F0);
  static const Color levelB1Dark = Color(0xFF6455DC);
  static const Color levelB2Dark = Color(0xFF5244C2);
  static const Color bookmarksCardDark = Color(0xFFC98A1B);
  static const Color unknownCardDark = Color(0xFFA06E10);
  static const Color quizCardDark = Color(0xFF2EAE86);
  static const Color listeningCardDark = Color(0xFF1F9A74);
  static const Color resultsCardDark = Color(0xFF177F5F);
  static const Color accentColorDark = Color(0xFFFBBF57);

  static const Color backgroundDark = Color(0xFF14121F);
  static const Color headerBgDark = Color(0xFF1B1830);
  static const Color surfaceDark = Color(0xFF1E1B2E);

  static const Color textPrimaryDark = Color(0xFFF3F1FA);
  static const Color textSecondaryDark = Color(0xFFA39FB8);

  static const Color borderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  static const Color successColorDark = Color(0xFF4ADE9A);
  static const Color successTintDark = Color(0x294ADE9A);
  static const Color warningColorDark = Color(0xFFFFB74D);
  static const Color warningTintDark = Color(0x24FFB74D);
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
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
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
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        primary: mainColor,
        onPrimary: Colors.white,
        primaryTint: primaryTint,
        levelA1: levelA1,
        levelA2: levelA2,
        levelB1: levelB1,
        levelB2: levelB2,
        bookmarksCard: bookmarksCard,
        unknownCard: unknownCard,
        quizCard: quizCard,
        listeningCard: listeningCard,
        resultsCard: resultsCard,
        accent: accentColor,
        surface: surfaceLight,
        headerBg: headerBgLight,
        textPrimary: textPrimaryLight,
        textSecondary: textSecondaryLight,
        border: borderLight,
        chipBg: chipBgLight,
        success: successColor,
        successTint: successTint,
        warning: warningColor,
        warningTint: warningTint,
        error: errorColor,
        errorTint: errorTint,
        info: mainColor,
        infoTint: primaryTint,
        shadow: Color(0x1F000000),
        shadowStrong: Color(0x241B1730),
        shadowMedium: Color(0x28000000),
        shadowSubtle: Color(0x14000000),
        barrier: Color(0x8A000000),
      ),
    ],
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
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
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
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        primary: mainColorDark,
        onPrimary: Colors.white,
        primaryTint: primaryTintDark,
        levelA1: levelA1Dark,
        levelA2: levelA2Dark,
        levelB1: levelB1Dark,
        levelB2: levelB2Dark,
        bookmarksCard: bookmarksCardDark,
        unknownCard: unknownCardDark,
        quizCard: quizCardDark,
        listeningCard: listeningCardDark,
        resultsCard: resultsCardDark,
        accent: accentColorDark,
        surface: surfaceDark,
        headerBg: headerBgDark,
        textPrimary: textPrimaryDark,
        textSecondary: textSecondaryDark,
        border: borderDark,
        chipBg: borderDark,
        success: successColorDark,
        successTint: successTintDark,
        warning: warningColorDark,
        warningTint: warningTintDark,
        error: errorColorDark,
        errorTint: errorTintDark,
        info: mainColorDark,
        infoTint: primaryTintDark,
        shadow: Color(0x1F000000),
        shadowStrong: Color(0x80000000),
        shadowMedium: Color(0x59000000),
        shadowSubtle: Color(0x26000000),
        barrier: Color(0x8A000000),
      ),
    ],
    useMaterial3: true,
  );
}
