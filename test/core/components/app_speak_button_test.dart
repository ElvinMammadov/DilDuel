import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dic/core/components/app_speak_button.dart';
import 'package:flutter_dic/core/state/speech_cubit.dart';
import 'package:flutter_dic/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_tts');
  late List<MethodCall> calls;

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return 1;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<SpeechCubit> pumpButton(WidgetTester tester) async {
    final SpeechCubit speech = SpeechCubit();
    addTearDown(speech.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AppSpeakButton(speech: speech, text: 'Haus'),
          ),
        ),
      ),
    );
    return speech;
  }

  testWidgets('shows the speaker icon while idle', (WidgetTester tester) async {
    await pumpButton(tester);

    check(find.byIcon(Icons.volume_up_outlined).evaluate()).isNotEmpty();
    check(find.byIcon(Icons.stop_rounded).evaluate()).isEmpty();
  });

  testWidgets('tapping reads the text and swaps to a stop icon', (
    WidgetTester tester,
  ) async {
    await pumpButton(tester);

    await tester.tap(find.byType(AppSpeakButton));
    await tester.pump();

    check(find.byIcon(Icons.stop_rounded).evaluate()).isNotEmpty();
    check(
      calls.where((MethodCall c) => c.method == 'speak').single.arguments,
    ).equals('Haus');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping again stops and restores the speaker icon', (
    WidgetTester tester,
  ) async {
    await pumpButton(tester);

    await tester.tap(find.byType(AppSpeakButton));
    await tester.pump();
    await tester.tap(find.byType(AppSpeakButton));
    await tester.pump();

    check(find.byIcon(Icons.volume_up_outlined).evaluate()).isNotEmpty();
  });
}
