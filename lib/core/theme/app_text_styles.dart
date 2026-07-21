import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text style definitions for the app.
///
/// All styles follow a consistent scale and accept a [Color] so they
/// work correctly in both light and dark themes.
///
/// Font families:
///  - Base (sans-serif): Plus Jakarta Sans
///  - Serif: Source Serif 4  — used for word display text
class AppTextStyles {
  static TextStyle get _base => GoogleFonts.plusJakartaSans();
  static TextStyle get _serif => GoogleFonts.sourceSerif4();

  // ─── Display ─────────────────────────────────────────────────

  /// 32 px · w800 — hero headings
  static TextStyle headlineLarge(Color c) => _base.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: c,
      letterSpacing: -0.5);

  /// 24 px · w700 · serif — decorative headings
  static TextStyle headlineMedium(Color c) =>
      _serif.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: c);

  // ─── Title scale ─────────────────────────────────────────────

  /// 22 px · w700 — score display, metric values
  static TextStyle scoreDisplay(Color c) =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: c);

  /// 20 px · w700 — section headings, result titles
  static TextStyle titleXLarge(Color c) =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: c);

  /// 19 px · w800 — screen / card titles
  static TextStyle titleLarge(Color c) =>
      _base.copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: c);

  /// 17 px · w700 — row titles, item names
  static TextStyle titleMedium(Color c) => _base.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: c,
      letterSpacing: -0.2);

  /// 15 px · w700 — compact buttons, tab labels, setting rows
  static TextStyle titleSmall(Color c) =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: c);

  // ─── Body scale ──────────────────────────────────────────────

  /// 19 px · w400 — prominent translation / definition text
  static TextStyle bodyXLarge(Color c) =>
      _base.copyWith(fontSize: 19, fontWeight: FontWeight.w400, color: c);

  /// 16 px · w400 — primary body copy
  static TextStyle bodyLarge(Color c) =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: c);

  /// 16 px · w700 — emphasized body text, answer options
  static TextStyle bodyLargeBold(Color c) =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: c);

  /// 14 px · w400 — secondary body copy, descriptions
  static TextStyle bodyMedium(Color c) =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: c);

  /// 13 px · w400 — subtitles, meta text, hints
  static TextStyle bodySmall(Color c) =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: c);

  // ─── Label scale ─────────────────────────────────────────────

  /// 14 px · w700 — CTA button labels, badge values
  static TextStyle labelLarge(Color c) =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: c);

  /// 13 px · w700 — compact labels, toggle text (e.g. Az / De switcher)
  static TextStyle labelMedium(Color c) =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: c);

  /// 12 px · w400 — captions, metric chip labels
  static TextStyle caption(Color c) =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: c);

  /// 11 px · w700 — bottom-nav labels, tiny badges
  static TextStyle labelSmall(Color c) =>
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: c);

  // ─── Specialised ─────────────────────────────────────────────

  /// Serif · w700 — source word display.
  /// [size] defaults to 18; pass a larger value for hero word views.
  static TextStyle wordSource(Color c, {double size = 18}) =>
      _serif.copyWith(fontSize: size, fontWeight: FontWeight.w700, color: c);
}

