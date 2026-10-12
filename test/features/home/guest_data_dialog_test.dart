import 'package:checks/checks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/features/auth/auth.dart';
import 'package:flutter_dic/features/home/widgets/guest_data_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _SpyAuthCubit extends Fake implements AuthCubit {
  final List<String> calls = <String>[];

  @override
  Future<void> keepGuestData() async => calls.add('keep');

  @override
  Future<void> discardGuestData() async => calls.add('discard');
}

void main() {
  late _SpyAuthCubit cubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Translations are not loaded here, so widgets show their keys.
    EasyLocalization.logger.enableLevels = <LevelMessages>[];
  });

  Future<void> openDialog(WidgetTester tester) async {
    cubit = _SpyAuthCubit();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => GuestDataDialog.show(context, cubit),
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

  testWidgets('shows the title, message and both actions', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    for (final String key in <String>[
      'auth.guest_data.title',
      'auth.guest_data.message',
      'auth.guest_data.keep',
      'auth.guest_data.discard',
    ]) {
      check(find.text(key).evaluate()).isNotEmpty();
    }
  });

  testWidgets('keep closes the dialog and keeps the guest data', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    await tester.tap(find.text('auth.guest_data.keep'));
    await tester.pumpAndSettle();

    check(cubit.calls).deepEquals(<String>['keep']);
    check(find.byType(GuestDataDialog).evaluate()).isEmpty();
  });

  testWidgets('discard closes the dialog and discards the guest data', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    await tester.tap(find.text('auth.guest_data.discard'));
    await tester.pumpAndSettle();

    check(cubit.calls).deepEquals(<String>['discard']);
    check(find.byType(GuestDataDialog).evaluate()).isEmpty();
  });

  testWidgets('the back gesture does not dismiss it', (
    WidgetTester tester,
  ) async {
    await openDialog(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    check(find.byType(GuestDataDialog).evaluate()).isNotEmpty();
    check(cubit.calls).isEmpty();
  });
}
