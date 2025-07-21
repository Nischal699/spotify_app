import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setAudioSource(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() async => _player.play();

  Future<void> pause() async => _player.pause();

  Future<void> stop() async => _player.stop();

  void dispose() {
    _player.dispose();
  }
}
