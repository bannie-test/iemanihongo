import 'dart:io' show Platform;

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
      if (Platform.isIOS) {
        // Play through the speaker even when the silent switch is on.
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ], IosTextToSpeechAudioMode.defaultMode);
      }
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
    _sequence++; // a single word interrupts any dialogue being read
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  int _sequence = 0;

  /// Reads lines one after another with a pitch per speaker. Starting a new
  /// sequence or calling [stop] cancels the running one.
  Future<void> speakLines(List<(String, double)> lines, {Duration gap = const Duration(milliseconds: 450)}) async {
    if (!_ready) return;
    final id = ++_sequence;
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(true);
      for (final (text, pitch) in lines) {
        if (id != _sequence) break;
        await _tts.setPitch(pitch);
        await _tts.speak(text);
        if (id != _sequence) break;
        await Future<void>.delayed(gap);
      }
    } catch (e) {
      debugPrint('TTS sequence failed: $e');
    } finally {
      if (id == _sequence) {
        await _tts.setPitch(1.0);
        await _tts.awaitSpeakCompletion(false);
      }
    }
  }

  Future<void> stop() async {
    _sequence++;
    if (_ready) {
      await _tts.stop();
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
    }
  }
}
