import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_snackbar.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> showSnackbar(WidgetTester tester, {String? subtitle}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppSnackbar.show(
                  context,
                  type: SnackbarType.success,
                  title: 'Title',
                  subtitle: subtitle,
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

  double iconCenterY(WidgetTester tester) =>
      tester.getCenter(find.byIcon(Icons.check_rounded)).dy;

  testWidgets('a lone title is vertically centred on the icon', (
    WidgetTester tester,
  ) async {
    await showSnackbar(tester);

    final double titleCenter = tester.getCenter(find.text('Title')).dy;
    check((titleCenter - iconCenterY(tester)).abs()).isLessThan(1);

    AppSnackbar.dismiss();
    await tester.pumpAndSettle();
  });

  testWidgets('with a subtitle the title stays above the icon centre', (
    WidgetTester tester,
  ) async {
    await showSnackbar(tester, subtitle: 'Subtitle');

    final double titleCenter = tester.getCenter(find.text('Title')).dy;
    check(titleCenter).isLessThan(iconCenterY(tester) - 1);
    check(find.text('Subtitle').evaluate()).isNotEmpty();

    AppSnackbar.dismiss();
    await tester.pumpAndSettle();
  });
}
