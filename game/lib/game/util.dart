import 'dart:convert';
import 'dart:math' as math;

import 'package:dartlin/dartlin.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

final R = math.Random();

const ENABLE_AUDIO = false;
const DEBUG = false;
const CHECK_PLAYER_ID = false;
const ENABLE_REVAMP = true;
const ENABLE_ADS = false;
const ENABLE_FIREBASE = false;
const ENABLE_SPLASH = false;

const BLOCK_SIZE = 16.0;
const BLOCK_SIZE_INT = 16;
const CHUNK_SIZE = 64;

const ROTATION_SPEED = 0.075;

const STARS_SPEED = 5.0;
const STARS_IDLE_SPEED = 2.0;
const PLANET_SPEED = 45.0;
const SHIPS_SPEED = 45.0;
const PLAYER_SPEED = 170.0;
const GRAVITY_ACC = 2750.0;

const STARTING_LIVES = 1;
const SUCTION_SPEED = 35.0;

Future<Map<String, dynamic>?> readPrefs(String name) async {
  final prefs = await SharedPreferences.getInstance();
  final pref = prefs.getString(name);
  return pref?.let((it) => json.decode(it) as Map<String, dynamic>);
}

Future<bool> writePrefs(String name, Map<String, dynamic> value) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.setString(name, json.encode(value));
}

class Fonts {
  static final TextPaint _base = TextPaint(
    style: const TextStyle(fontFamily: 'Quantum'),
  );
  static final TextPaint menuTitle = _base.copyWith(
    (it) => it.copyWith(fontSize: 64.0, color: Palette.menuTitleText.color),
  );
  static final TextPaint menuItems = _base.copyWith(
    (it) => it.copyWith(fontSize: 28.0, color: Palette.menuItemsText.color),
  );
  static final TextPaint gameOverItems = _base.copyWith(
    (it) => it.copyWith(fontSize: 16.0, color: Palette.menuItemsText.color),
  );
  static final TextPaint hud = _base.copyWith(
    (it) => it.copyWith(fontSize: 16.0, color: Palette.hud.color),
  );
  static final TextPaint tutorial = _base.copyWith(
    (it) => it.copyWith(fontSize: 24.0, color: Palette.hud.color),
  );
}

extension Clear on Component {
  void clear() {
    removeAll(children);
  }
}