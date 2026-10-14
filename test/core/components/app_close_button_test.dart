import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_close_button.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('runs the callback when tapped', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(child: AppCloseButton(onTap: () => taps++)),
        ),
      ),
    );

    await tester.tap(find.byType(AppCloseButton));

    check(taps).equals(1);
  });

  testWidgets('is announced as a button named Close', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(child: AppCloseButton(onTap: () {})),
        ),
      ),
    );

    check(find.bySemanticsLabel('Close').evaluate()).isNotEmpty();
    handle.dispose();
  });

  testWidgets('closes a bottom sheet', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext ctx) => Center(
                  child: AppCloseButton(onTap: () => Navigator.of(ctx).pop()),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    check(find.byType(AppCloseButton).evaluate()).isNotEmpty();

    await tester.tap(find.byType(AppCloseButton));
    await tester.pumpAndSettle();

    check(find.byType(AppCloseButton).evaluate()).isEmpty();
  });
}
