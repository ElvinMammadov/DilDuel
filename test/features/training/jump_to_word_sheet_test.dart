import 'package:checks/checks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_bottom_sheet.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/features/training/training.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  const int total = 200;
  late List<int> jumps;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Translations are not loaded here, so widgets show their keys.
    EasyLocalization.logger.enableLevels = <LevelMessages>[];
  });

  /// Opens the sheet from a button, as the app does, so that closing it has
  /// a route to pop.
  Future<void> openSheet(WidgetTester tester, {int currentIndex = 4}) async {
    jumps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppBottomSheet.show<void>(
                  context,
                  isScrollControlled: true,
                  child: JumpToWordSheet(
                    total: total,
                    currentIndex: currentIndex,
                    wordAt: (int index) => 'word${index + 1}',
                    onJump: jumps.add,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on the current word', (WidgetTester tester) async {
    await openSheet(tester);

    check(find.text('word5').evaluate()).isNotEmpty();
    check(tester.widget<TextField>(find.byType(TextField)).controller!.text)
        .equals('5');
  });

  testWidgets('typing a number previews that word', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();

    check(find.text('word42').evaluate()).isNotEmpty();
  });

  testWidgets('a typed number past the end is clamped', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '999');
    await tester.pump();

    check(find.text('word$total').evaluate()).isNotEmpty();
    check(tester.widget<TextField>(find.byType(TextField)).controller!.text)
        .equals('$total');
  });

  testWidgets('dragging the slider changes the selected word', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, currentIndex: 0);

    await tester.drag(find.byType(Slider), const Offset(300, 0));
    await tester.pump();

    final Slider slider = tester.widget<Slider>(find.byType(Slider));
    check(slider.value).isGreaterThan(0);
  });

  testWidgets('the last quick chip selects the final word', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.text('training.jump.end'));
    await tester.pump();

    check(find.text('word$total').evaluate()).isNotEmpty();
  });

  testWidgets('confirming jumps to the chosen zero-based index', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    check(jumps).deepEquals(<int>[41]);
    check(find.byType(JumpToWordSheet).evaluate()).isEmpty();
  });

  testWidgets('confirming without a change does not jump', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    check(jumps).isEmpty();
    check(find.byType(JumpToWordSheet).evaluate()).isEmpty();
  });
}
