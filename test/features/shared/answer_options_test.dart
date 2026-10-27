import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_dic/features/shared/widgets/answer_options.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, List<String> answers) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AnswerOptions(
            options: const <String>['eins', 'zwei', 'drei'],
            correctAnswer: 'zwei',
            onAnswer: answers.add,
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows no Next button until an option is chosen', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <String>[]);

    check(find.text('quiz.next').evaluate()).isEmpty();

    await tester.tap(find.text('eins'));
    await tester.pump();

    check(find.text('quiz.next').evaluate()).isNotEmpty();
  });

  testWidgets('locks the first choice and reports it on Next', (
    WidgetTester tester,
  ) async {
    final List<String> answers = <String>[];
    await _pump(tester, answers);

    await tester.tap(find.text('eins'));
    await tester.pump();
    await tester.tap(find.text('drei'));
    await tester.pump();
    await tester.tap(find.text('quiz.next'));
    await tester.pump();

    check(answers).deepEquals(<String>['eins']);
  });

  testWidgets('resets for the next question after Next', (
    WidgetTester tester,
  ) async {
    await _pump(tester, <String>[]);

    await tester.tap(find.text('zwei'));
    await tester.pump();
    await tester.tap(find.text('quiz.next'));
    await tester.pump();

    check(find.text('quiz.next').evaluate()).isEmpty();
  });
}
