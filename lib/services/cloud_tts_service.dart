// lib/services/cloud_tts_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class CloudTtsService {
  // --- IMPORTANT ---
  // Paste the API key you generated from the Google Cloud Console here.
  // For a real-world, published app, it's more secure to hide this key
  // on a server, but for a personal project, this is the simplest method.
  final String _apiKey = 'AIzaSyDjsIxA1gOe8EaEZflPq1hnDVsOpSR9G0s';

  final String _url = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  final AudioPlayer _audioPlayer = AudioPlayer();

  // A simple cache to store audio data for words we've already fetched.
  final Map<String, String> _audioCache = {};

  Future<void> speak(String text) async {
    // If we've already fetched this audio, play it from the cache.
    if (_audioCache.containsKey(text)) {
      await _playAudio(_audioCache[text]!);
      return;
    }

    // If not cached, make a new request to the API.
    try {
      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'input': {'text': text},
          'voice': {
            'languageCode': 'nl-NL',
            'name':
                'nl-NL-Chirp3-HD-Achernar' // The high-quality voice you chose!
          },
          'audioConfig': {'audioEncoding': 'MP3'} // Request MP3 format
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final String audioContent = body['audioContent'];

        // Save the audio to our cache...
        _audioCache[text] = audioContent;
        // ...and play it.
        await _playAudio(audioContent);
      } else {
        // Handle API errors
        print('Cloud TTS Error: ${response.body}');
      }
    } catch (e) {
      print('Failed to call Cloud TTS API: $e');
    }
  }

  Future<void> _playAudio(String base64Audio) async {
    // The audioplayers package can play audio directly from a base64 source.
    await _audioPlayer.play(BytesSource(base64Decode(base64Audio)));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
