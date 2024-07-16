import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/util.dart';

enum JetpackType { REGULAR, PULSER }

class JetpackPickup extends SpriteComponent with HasGameRef<MyGame> {
  static const HOVER_TIME = 1.0;
  static const HOVER_DISTANCE = 4;

  static const JETPACK_DURATION = 15.0;

  late final Sprite jetpack;
  late final SpriteAnimationTicker pulser;

  JetpackType type;
  double hoverClock = 0.0;
  late double startY;

  JetpackPickup(this.type, double x, double y) {
    this.x = x;
    this.y = startY = y;
    width = height = BLOCK_SIZE;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    jetpack = await Sprite.load('jetpack.png');
    pulser = SpriteAnimationTicker(
      await SpriteAnimation.load(
        'pulser.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2.all(16),
          loop: false,
          stepTime: 0.15,
        ),
      ),
    )..setToLast();
  }

  @override
  Sprite get sprite => getSpriteForType();

  Sprite getSpriteForType() {
    return type == JetpackType.REGULAR
        ? jetpack
        : pulser.spriteAnimation.frames[0].sprite;
  }

  SpriteAnimationTicker getAnimationForType(JetpackType type) {
    final animation = type == JetpackType.REGULAR
        ? SpriteAnimation.spriteList([jetpack], stepTime: 0)
        : pulser.spriteAnimation.clone();
    return SpriteAnimationTicker(animation);
  }

  @override
  void update(double t) {
    super.update(t);

    hoverClock = (hoverClock + t / HOVER_TIME) % 1.0;
    final dy = 1 - (2 * hoverClock - 1).abs() * HOVER_DISTANCE;
    y = startY + dy;

    if (gameRef.player.toRect().overlaps(toRect())) {
      gameRef.player.jetpackType = type;
      gameRef.player.jetpackAnimation = getAnimationForType(type);
      gameRef.player.jetpackTimeout = JETPACK_DURATION;
      gameRef.player.hovering = false;
      removeFromParent();
    }
  }

  @override
  int get priority => 4;
}
