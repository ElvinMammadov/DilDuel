import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/bottom_sheet_theme.dart';

class AppTheme {
  // Spacing
  static const double spacing = 8.0;
  static const double spacingSmall = spacing / 2;
  static const double spacingLarge = spacing * 2;
  static const double spacingXLarge = spacing * 3;

  // Border Radius
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 12.0;
  static BorderRadius standardBorderRadius =
      BorderRadius.circular(borderRadius);
  static BorderRadius largeBorderRadius =
      BorderRadius.circular(borderRadiusLarge);

  // Elevations
  static const double elevationSmall = 1.0;
  static const double elevationNormal = 2.0;
  static const double elevationLarge = 4.0;

  // Primary Colors
  static const Color mainColor = Color(0xFF4A90E2); // Blue
  static const Color secondaryColor = Color(0xFF757575); // Grey
  static const Color accentColor = Color(0xFFE0E0E0); // Light Grey

  // State Colors
  static const Color successColor = Color(0xFF66BB6A); // Green
  static const Color warningColor = Color(0xFFFFB74D); // Orange
  static const Color errorColor = Color(0xFFE57373); // Red
  static const Color infoColor = Color(0xFF64B5F6); // Light Blue

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Very Light Grey
  static const Color backgroundDark = Color(0xFF303030); // Dark Grey
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Colors.white;

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF424242); // Dark Grey
  static const Color textSecondaryLight = Color(0xFF757575); // Medium Grey
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // Light Grey

  // UI Element Colors
  static const Color iconColor = mainColor;
  static const Color buttonColor = mainColor;
  static const Color highlightColor = Color(0xFF90CAF9); // Light Blue
  static const Color disabledColor = Color(0xFFBDBDBD); // Medium Grey
  static const Color dividerColor = Color(0xFFEEEEEE); // Very Light Grey
  static const Color shadowColor = Color(0x1F000000); // 12% black

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: textPrimaryLight,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimaryLight,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: textPrimaryLight,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: textPrimaryLight,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: textSecondaryLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: mainColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: highlightColor.withValues(alpha: 0.2),
      foregroundColor: textPrimaryLight,
      elevation: elevationSmall,
      shadowColor: shadowColor,
    ),
    bottomSheetTheme: const CustomBottomSheetTheme(),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: elevationSmall,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: standardBorderRadius,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
    ),
    useMaterial3: true,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: mainColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: Color(0xFF424242),
      onSurface: textPrimaryDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      foregroundColor: Colors.white,
      elevation: elevationSmall,
      shadowColor: shadowColor,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF424242),
      elevation: elevationSmall,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: standardBorderRadius,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF616161),
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineLarge: headlineLarge.copyWith(color: textPrimaryDark),
      headlineMedium: headlineMedium.copyWith(color: textPrimaryDark),
      titleLarge: titleLarge.copyWith(color: textPrimaryDark),
      bodyLarge: bodyLarge.copyWith(color: textPrimaryDark),
      bodyMedium: bodyMedium.copyWith(color: textSecondaryDark),
    ),
    useMaterial3: true,
  );
}
