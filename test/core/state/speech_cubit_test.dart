import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dic/core/state/speech_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  List<Object?> spoken() => calls
      .where((MethodCall call) => call.method == 'speak')
      .map((MethodCall call) => call.arguments)
      .toList();

  Future<void> finishSpeaking() => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .handlePlatformMessage(
        'flutter_tts',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('speak.onComplete', true),
        ),
        (_) {},
      );

  test('configures German at a slowed speech rate', () {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    check(calls.map((MethodCall call) => call.method).toList())
      ..contains('setLanguage')
      ..contains('setSpeechRate');
    check(
      calls.firstWhere((MethodCall c) => c.method == 'setLanguage'),
    ).has((MethodCall c) => c.arguments, 'arguments').equals('de-DE');
  });

  test('speak marks speaking and reads the text', () async {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    await cubit.speak('Haus');

    check(cubit.state).isTrue();
    check(spoken()).deepEquals(<Object?>['Haus']);
  });

  test('toggle while speaking stops instead of speaking again', () async {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    await cubit.toggle('Haus');
    await cubit.toggle('Haus');

    check(cubit.state).isFalse();
    check(spoken()).deepEquals(<Object?>['Haus']);
  });

  test('the platform finishing speech clears the speaking state', () async {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    await cubit.speak('Haus');
    await finishSpeaking();

    check(cubit.state).isFalse();
  });

  test('speakQuietly reads the text without marking speaking', () async {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    await cubit.speakQuietly('Wohnung');

    check(cubit.state).isFalse();
    check(spoken()).deepEquals(<Object?>['Wohnung']);
  });

  test('speakQuietly clears the indicator of the word it interrupts', () async {
    final SpeechCubit cubit = SpeechCubit();
    addTearDown(cubit.close);

    await cubit.speak('Haus');
    await cubit.speakQuietly('Wohnung');

    check(cubit.state).isFalse();
  });

  test('closing stops speech and ignores a late completion callback', () async {
    final SpeechCubit cubit = SpeechCubit();
    await cubit.speak('Haus');

    await cubit.close();
    await finishSpeaking();

    check(calls.where((MethodCall c) => c.method == 'stop')).isNotEmpty();
  });
}
