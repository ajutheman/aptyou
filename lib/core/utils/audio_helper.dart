import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String assetPath) async {
    try {
      await _player.stop(); // Stop any current sound
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
