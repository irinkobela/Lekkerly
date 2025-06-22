// lib/services/cloud_tts_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:lekkerly/api_keys.dart'; // Import the new secret file

class CloudTtsService {
  // The API key is now loaded securely from the api_keys.dart file.
  final String _apiKey = googleCloudApiKey;

  final String _url = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, String> _audioCache = {};

  Future<void> speak(String text) async {
    if (_audioCache.containsKey(text)) {
      await _playAudio(_audioCache[text]!);
      return;
    }

    // Check if the API key has been set.
    if (_apiKey == 'PASTE_YOUR_NEW_API_KEY_HERE' || _apiKey.isEmpty) {
      print('API Key is not set in lib/api_keys.dart. Please add it.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'input': {'text': text},
          'voice': {
            'languageCode': 'nl-NL',
            'name': 'nl-NL-Chirp3-HD-Achernar'
          },
          'audioConfig': {'audioEncoding': 'MP3'}
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final String audioContent = body['audioContent'];
        _audioCache[text] = audioContent;
        await _playAudio(audioContent);
      } else {
        print('Cloud TTS Error: ${response.body}');
      }
    } catch (e) {
      print('Failed to call Cloud TTS API: $e');
    }
  }

  Future<void> _playAudio(String base64Audio) async {
    await _audioPlayer.play(BytesSource(base64Decode(base64Audio)));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
