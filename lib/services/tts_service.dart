import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Japanese pronunciation using the device's built-in text-to-speech engine,
/// which works offline once a Japanese voice is installed.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  /// null until checked; false means no Japanese voice is installed.
  final ValueNotifier<bool?> japaneseAvailable = ValueNotifier(null);

  Future<void> init(double rate) async {
    try {
      await _tts.awaitSpeakCompletion(false);
      final available = await _tts.isLanguageAvailable('ja-JP');
      japaneseAvailable.value = available == true;
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(1.0);
      _ready = true;
    } catch (e) {
      debugPrint('TTS init failed: $e');
      japaneseAvailable.value = false;
    }
  }

  Future<void> setRate(double rate) async {
    if (_ready) await _tts.setSpeechRate(rate);
  }

  Future<void> speak(String text) async {
    if (!_ready) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    if (_ready) await _tts.stop();
  }
}
