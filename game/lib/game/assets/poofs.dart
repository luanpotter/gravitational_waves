import 'package:flame/components.dart';
import 'package:gravitational_waves/game/assets/spritesheet.dart';

class Poofs {
  static late Spritesheet _sheet;

  static SpriteAnimation poof() => _animation('poof')..loop = false;
  static SpriteAnimation airEscaping() => _animation('air_escaping');
  static SpriteAnimation glassBreaking() =>
      _animation('glass_breaking')..loop = false;

  static Future init() async {
    _sheet = await Spritesheet.parse('poofs');
  }

  static SpriteAnimation _animation(String name) {
    return _sheet.animation(name);
  }
}
