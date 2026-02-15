import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech Status: $status'),
      onError: (error) => debugPrint('Speech Error: $error'),
    );
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) {
      debugPrint('Speech recognition not available');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
