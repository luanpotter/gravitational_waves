import 'package:flame/components.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/util.dart';

class SpaceBattle extends SpriteAnimationComponent with HasGameRef<MyGame> {
  static const S = 1.0;
  static const TX_W = 112.0;
  static const TX_H = 80.0;

  bool spawnedShip = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await SpriteAnimation.load(
      'space-battle.png',
      SpriteAnimationData.sequenced(
        amount: 12,
        textureSize: Vector2(TX_W, TX_H),
        stepTime: 0.15,
      ),
    );
    size = Vector2(S * TX_W, S * TX_H);
    x = gameRef.size.x + width;
    y = (gameRef.size.y - height) / 2 + (R.nextDouble() - 0.5) * height / 2;
  }

  @override
  void update(double t) {
    super.update(t);
    x -= SHIPS_SPEED * t;

    if (!spawnedShip && x < (gameRef.size.x - width) / 2) {
      gameRef.powerups.spawnFiringShip();
      spawnedShip = true;
    }

    if (x < -width) {
      removeFromParent();
    }
  }

  @override
  int get priority => 1;
}
