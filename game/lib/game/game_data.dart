import 'dart:async';
import 'dart:math' as math;

import 'package:gravitational_waves/game/skin.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  static late GameData instance;

  int coins;
  Skin selectedSkin;
  List<Skin> ownedSkins;
  String? playerId;
  int? highScore;

  GameData()
      : coins = 0,
        highScore = null,
        selectedSkin = Skin.ASTRONAUT,
        ownedSkins = [Skin.ASTRONAUT],
        playerId = null;

  Future<bool> buyAndSetSkin(Skin skin) async {
    final price = skinPrice(skin);
    if (ownedSkins.contains(skin)) {
      selectedSkin = skin;
    } else if (coins >= price) {
      coins -= price;
      ownedSkins.add(skin);
      selectedSkin = skin;
    } else {
      return false;
    }

    await save();
    return true;
  }

  Future addCoins(int coins) async {
    this.coins += coins;
    await save();
  }

  Future changeSkin(Skin skin) async {
    selectedSkin = skin;
    await save();
  }

  Future addScore(int score) async {
    highScore = math.max(highScore ?? 0, score);
    await save();
  }

  Future setPlayerId(String playerId) async {
    this.playerId = playerId;
    await save();
  }

  bool isFirstTime() => highScore == null;

  static Future<GameData> init() async {
    return instance = await load();
  }

  Future<bool> save() => writePrefs('gravitational_waves.data', toJson());

  static Future<GameData> load() async {
    final json = await readPrefs('gravitational_waves.data');
    if (json != null) {
      return GameData.fromJson(json);
    } else {
      return GameData();
    }
  }

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);
  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}
