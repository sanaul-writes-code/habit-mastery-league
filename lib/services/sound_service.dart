import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playTap() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/tap.mp3'));
  }

  static Future<void> playOpen() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/open.mp3'));
  }

  static Future<void> playSave() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/save.mp3'));
  }

  static Future<void> playComplete() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/complete.mp3'));
  }

  static Future<void> playDelete() async {
    await _player.stop();
    await _player.play(AssetSource('sounds/delete.mp3'));
  }
}
