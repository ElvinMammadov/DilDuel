import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_dialog.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpDialog(WidgetTester tester, AppDialog dialog) =>
      tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: Scaffold(body: dialog)),
      );

  testWidgets('shows title, message, body and both actions', (
    WidgetTester tester,
  ) async {
    await pumpDialog(
      tester,
      AppDialog(
        icon: Icons.info_outline,
        title: 'Title',
        message: 'Message',
        body: const Text('Body'),
        primary: AppDialogAction(label: 'Primary', onPressed: () {}),
        secondary: AppDialogAction(label: 'Secondary', onPressed: () {}),
      ),
    );

    for (final String text in <String>[
      'Title',
      'Message',
      'Body',
      'Primary',
      'Secondary',
    ]) {
      check(find.text(text).evaluate()).isNotEmpty();
    }
  });

  testWidgets('runs the tapped action', (WidgetTester tester) async {
    final List<String> taps = <String>[];
    await pumpDialog(
      tester,
      AppDialog(
        icon: Icons.info_outline,
        title: 'Title',
        primary: AppDialogAction(
          label: 'Primary',
          onPressed: () => taps.add('primary'),
        ),
        secondary: AppDialogAction(
          label: 'Secondary',
          onPressed: () => taps.add('secondary'),
        ),
      ),
    );

    await tester.tap(find.text('Secondary'));
    await tester.tap(find.text('Primary'));

    check(taps).deepEquals(<String>['secondary', 'primary']);
  });

  testWidgets('a loading primary action swaps its label for a spinner and '
      'a null callback disables the secondary one', (
    WidgetTester tester,
  ) async {
    await pumpDialog(
      tester,
      AppDialog(
        icon: Icons.delete_outline,
        title: 'Title',
        primary: AppDialogAction(
          label: 'Delete',
          isLoading: true,
          onPressed: () {},
        ),
        secondary: const AppDialogAction(label: 'Cancel', onPressed: null),
      ),
    );

    check(find.text('Delete').evaluate()).isEmpty();
    check(find.byType(CircularProgressIndicator).evaluate()).isNotEmpty();
    check(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
    ).isNull();
  });
}
