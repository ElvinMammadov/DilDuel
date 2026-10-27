import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_bottom_sheet.dart';
import 'package:flutter_dic/core/components/app_close_button.dart';
import 'package:flutter_dic/core/components/app_drag_handle.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpSheet(WidgetTester tester, AppBottomSheet sheet) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: sheet),
        ),
      );

  testWidgets('shows the drag handle, title, close button and content', (
    WidgetTester tester,
  ) async {
    await pumpSheet(
      tester,
      const AppBottomSheet(title: 'Choose', child: Text('Content')),
    );

    check(find.byType(AppDragHandle).evaluate()).isNotEmpty();
    check(find.text('Choose').evaluate()).isNotEmpty();
    check(find.byType(AppCloseButton).evaluate()).isNotEmpty();
    check(find.text('Content').evaluate()).isNotEmpty();
  });

  testWidgets('close button runs onClose when one is given', (
    WidgetTester tester,
  ) async {
    int closed = 0;
    await pumpSheet(
      tester,
      AppBottomSheet(
        title: 'Choose',
        onClose: () => closed++,
        child: const SizedBox.shrink(),
      ),
    );

    await tester.tap(find.byType(AppCloseButton));

    check(closed).equals(1);
  });

  testWidgets('close button dismisses the sheet by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: TextButton(
              onPressed: () => AppBottomSheet.show<void>(
                context,
                child: const AppBottomSheet(
                  title: 'Choose',
                  child: SizedBox.shrink(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    check(find.text('Choose').evaluate()).isNotEmpty();

    await tester.tap(find.byType(AppCloseButton));
    await tester.pumpAndSettle();

    check(find.text('Choose').evaluate()).isEmpty();
  });
}
