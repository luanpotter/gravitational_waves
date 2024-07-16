import 'package:flame/components.dart';
import 'package:gravitational_waves/game/collections.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/util.dart';

class FiringShip extends SpriteAnimationComponent with HasGameRef<MyGame> {
  static const scaleFactor = 2.0;
  static final textureSize = Vector2(80.0, 48.0);
  static const APPROXIMATION_TIME = 2.0;
  static const FIRING_TIME = 4.0;

  double myScale = 0;
  double clock = 0.0;

  late List<double> beforeHoleScales;
  late List<double> afterHoleScales;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await SpriteAnimation.load(
      'firing-ship.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: textureSize,
        stepTime: 0.15,
      ),
    )
      ..loop = true;

    size = textureSize * scaleFactor;
    position = gameRef.size / 2;
    anchor = Anchor.center;

    final beforeHoles = R.nextInt(2);
    final afterHoles = 1 + R.nextInt(2);

    double timing(int _) => R.doubleBetween(0.5, 0.85);
    beforeHoleScales = List.generate(beforeHoles, timing)..sort();
    afterHoleScales = List.generate(afterHoles, timing)..sort();
  }

  @override
  void update(double t) {
    myScale += t / APPROXIMATION_TIME;
    myScale = myScale.clamp(0.0, 1.0);

    if (myScale >= 0.5) {
      bool pred(double e) => myScale > e;
      if (beforeHoleScales.popIf(pred) != null) {
        gameRef.wall.spawnBrokenGlass(before: true);
      }
      if (afterHoleScales.popIf(pred) != null) {
        gameRef.wall.spawnBrokenGlass(before: false);
      }
    }

    if (myScale >= 0.8) {
      // tick animation
      super.update(t);
      clock += t;
      y -= SHIPS_SPEED * t;
    }

    if (y < -height) {
      removeFromParent();
      gameRef.powerups.hasSpaceBattle = false;
    }
  }

  @override
  int get priority => 1;
}
