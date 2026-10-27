import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads German text aloud and emits whether speech is currently playing.
///
/// Create one per screen or sheet that speaks and [close] it with the
/// screen, which also stops any speech still playing.
class SpeechCubit extends Cubit<bool> {
  SpeechCubit({FlutterTts? tts, String language = 'de-DE'})
    : _tts = tts ?? FlutterTts(),
      super(false) {
    _tts.setLanguage(language);
    _tts.setSpeechRate(_speechRate);
    _tts.setCompletionHandler(_onFinished);
  }

  static const double _speechRate = 0.5;

  final FlutterTts _tts;

  /// Stops speech if [text] is playing, otherwise starts reading it.
  Future<void> toggle(String text) => state ? stop() : speak(text);

  /// Reads [text], replacing anything already playing.
  Future<void> speak(String text) async {
    await _tts.stop();
    if (isClosed) return;
    emit(true);
    await _tts.speak(text);
  }

  /// Reads [text] without marking the speaking state, for secondary entries
  /// that have no indicator of their own.
  Future<void> speakQuietly(String text) async {
    await _tts.stop();
    if (isClosed) return;
    emit(false);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    if (!isClosed) emit(false);
  }

  void _onFinished() {
    if (!isClosed) emit(false);
  }

  @override
  Future<void> close() {
    _tts.stop();
    return super.close();
  }
}
