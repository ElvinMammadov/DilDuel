import 'package:flutter/material.dart';

class AppTheme {
  static const Color mainColor =
      Color(0xFF4A90E2);
  static const Color secondaryColor =
      Color(0xFF2C2C2E);
  static const Color accentColor =
      Color(0xFFE5E5EA);
  static const Color successColor =
      Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFFCC00);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color iconColor = Color(0xFF4A90E2);
  static const Color buttonColor = Color(0xFF00BFA6);
  static const Color highlightColor = Color(0xFFFF6F61);
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: mainColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      error: errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Color(0xFF444444),
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.black,
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    useMaterial3: true,
  );
}
