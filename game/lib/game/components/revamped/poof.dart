import 'package:flame/components.dart';
import 'package:gravitational_waves/game/assets/poofs.dart';
import 'package:gravitational_waves/game/game.dart';

class Poof extends SpriteAnimationComponent with HasGameRef<MyGame> {
  static const double SIZE = 16.0;

  Poof(double x, double y)
      : super(
          animation: Poofs.poof(),
          removeOnFinish: true,
          size: Vector2.all(SIZE),
          position: Vector2(x, y) - Vector2.all(SIZE) / 2,
        );

  @override
  int get priority => 5;
}
