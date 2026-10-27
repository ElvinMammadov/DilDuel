import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_colors.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/core/utils/article_color.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<AppColors> pumpColors(WidgetTester tester) async {
    late AppColors colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) {
            colors = AppColors.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return colors;
  }

  testWidgets('der is blue, die is red and das is green', (
    WidgetTester tester,
  ) async {
    final AppColors colors = await pumpColors(tester);

    check(
      articleColor('der', colors, isDark: false),
    ).equals(const Color(0xFF1565C0));
    check(
      articleColor('der', colors, isDark: true),
    ).equals(const Color(0xFF82B1FF));
    check(articleColor('die', colors, isDark: false)).equals(colors.error);
    check(articleColor('das', colors, isDark: false)).equals(colors.success);
  });

  testWidgets('matching ignores case', (WidgetTester tester) async {
    final AppColors colors = await pumpColors(tester);

    check(articleColor('DIE', colors, isDark: false)).equals(colors.error);
  });

  testWidgets('anything else is secondary text with no tint', (
    WidgetTester tester,
  ) async {
    final AppColors colors = await pumpColors(tester);

    check(
      articleColor(null, colors, isDark: false),
    ).equals(colors.textSecondary);
    check(
      articleTintColor('ein', colors, isDark: false),
    ).equals(Colors.transparent);
  });

  testWidgets('the tint is the article colour at low opacity', (
    WidgetTester tester,
  ) async {
    final AppColors colors = await pumpColors(tester);

    check(
      articleTintColor('das', colors, isDark: false),
    ).equals(colors.success.withAlpha(28));
  });
}
