import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/components/app_pill.dart';
import 'package:flutter_dic/core/utils/dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPill(WidgetTester tester, AppPill pill) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: pill)),
    ),
  );

  BoxDecoration decoration(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(AppPill),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  testWidgets('paints its colour with a fully rounded shape', (
    WidgetTester tester,
  ) async {
    await pumpPill(
      tester,
      const AppPill(color: Colors.red, child: Text('der')),
    );

    final BoxDecoration box = decoration(tester);
    check(box.color).equals(Colors.red);
    check(box.border).isNull();
    check(
      box.borderRadius,
    ).equals(BorderRadius.circular(Dimensions.borderRadiusPill));
  });

  testWidgets('draws an outline only when given a border colour', (
    WidgetTester tester,
  ) async {
    await pumpPill(
      tester,
      const AppPill(
        color: Colors.transparent,
        borderColor: Colors.blue,
        child: Text('Verb'),
      ),
    );

    check(decoration(tester).border).equals(Border.all(color: Colors.blue));
  });
}
