import 'package:flame_audio/flame_audio.dart';
import 'package:gravitational_waves/game/preferences.dart';
import 'package:gravitational_waves/game/util.dart';

class Audio {
  static final AudioPlayer musicPlayer = _createLoopingPlayer(
    prefix: 'assets/audio/',
  );

  static AudioPlayer _createLoopingPlayer({required String prefix}) {
    final player = AudioPlayer();
    player.audioCache = AudioCache(prefix: prefix);
    player.setReleaseMode(ReleaseMode.loop);
    return player;
  }

  static Future init() async {
    if (!ENABLE_AUDIO) {
      return;
    }
  }

  static void coin() {
    sfx('coin.wav', volume: 0.5);
  }

  static void die() {
    sfx('die.wav');
  }

  static void sfx(String sound, {double volume = 1.0}) {
    if (!ENABLE_AUDIO) {
      return;
    }
    if (!Preferences.instance.soundOn) {
      return;
    }

    FlameAudio.play('sfx/$sound');
  }

  static Future<void> music(String song) async {
    if (!ENABLE_AUDIO) {
      return;
    }
    if (!Preferences.instance.musicOn) {
      return;
    }
    await musicPlayer.play(AssetSource('music/$song'));
  }

  static Future<void> stopMusic() async {
    await musicPlayer.stop();
  }

  static Future<void> pauseMusic() async {
    await musicPlayer.pause();
  }

  static Future<void> resumeMusic() async {
    await musicPlayer.resume();
  }

  static Future<void> gameMusic() async {
    return music('dark-moon.mp3');
  }

  static Future<void> menuMusic() async {
    return music('contemplative-breaks.mp3');
  }
}
