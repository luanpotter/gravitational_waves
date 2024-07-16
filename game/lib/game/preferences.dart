import 'dart:async';

import 'package:gravitational_waves/game/audio.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

@JsonSerializable()
class Preferences {
  static late Preferences instance;

  bool musicOn;
  bool soundOn;
  bool rumbleOn;
  String language;

  Preferences()
      : musicOn = true,
        soundOn = true,
        rumbleOn = true,
        language = 'en_US';

  Future toggleMusic() async {
    musicOn = !musicOn;
    if (!musicOn) {
      Audio.stopMusic();
    } else {
      Audio.menuMusic();
    }
    await save();
  }

  Future toggleSounds() async {
    soundOn = !soundOn;
    await save();
  }

  Future toggleRumble() async {
    rumbleOn = !rumbleOn;
    await save();
  }

  static Future<Preferences> init() async {
    return instance = await load();
  }

  Future<bool> save() => writePrefs('gravitational_waves.prefs', toJson());

  static Future<Preferences> load() async {
    final json = await readPrefs('gravitational_waves.prefs');
    if (json != null) {
      return Preferences.fromJson(json);
    } else {
      return Preferences();
    }
  }

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
