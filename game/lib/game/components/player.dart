import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:gravitational_waves/game/assets/char.dart';
import 'package:gravitational_waves/game/components/background.dart';
import 'package:gravitational_waves/game/components/player_particles.dart';
import 'package:gravitational_waves/game/components/revamped/jetpack_pickup.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:gravitational_waves/game/rumble.dart';
import 'package:gravitational_waves/game/util.dart';

class Player extends PositionComponent with HasGameRef<MyGame> {
  static const HURT_TIMER = 2.0;
  static const SHINE_TIMER = 0.25;

  double speedY;
  int livesLeft;

  double hurtTimer = 0;
  double shinyTimer = 0;
  double invulnerabilityTimer = 0;

  JetpackType? jetpackType;
  SpriteAnimationTicker? jetpackAnimation;
  double jetpackTimeout = 0;
  bool hovering = false;

  PlayerParticles particles;

  Vector2? suctionCenter;
  double myScale = 1.0;

  double? deathDt;

  Player()
      : speedY = 0.0,
        livesLeft = STARTING_LIVES,
        particles = PlayerParticles(),
        super(size: Vector2.all(BLOCK_SIZE)) {
    reset();
  }

  void reset() {
    myScale = 1.0;
    hurtTimer = 0.0;
    shinyTimer = 0.0;
    invulnerabilityTimer = 0;
    jetpackTimeout = 0.0;
    hovering = false;
  }

  void extraLife() {
    reset();
    livesLeft++;
    hurtTimer = 0.5;
    invulnerabilityTimer = 0.5; // start with half a second of invulnerability
    // run one update just to skip the death cliff
    updatePosition(deathDt!);
  }

  bool get shouldFlip => gameRef.gravity > 0;

  bool get hurt => hurtTimer > 0.0;

  bool get invulnerable => invulnerabilityTimer > 0.0;

  bool get shiny => shinyTimer > 0.0;

  bool get dead => livesLeft == 0;

  bool get jetpack => jetpackTimeout > 0.0;

  bool get pulserJetpack => jetpack && jetpackType == JetpackType.PULSER;

  bool get regularJetpack => jetpack && jetpackType == JetpackType.REGULAR;

  Paint get _paint {
    if (shiny) {
      return Paint()
        ..colorFilter =
            ColorFilter.mode(Palette.playerShine.color, BlendMode.srcATop);
    }
    final blinkHurt = hurt && (hurtTimer * 1000) % 250 > 125;
    final palette = blinkHurt ? Palette.playerHurt : Palette.player;
    return palette.paint();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    y = getCurrentRect().bottom - BLOCK_SIZE;
  }

  @override
  void render(Canvas c) {
    super.render(c);

    final skin = Char.fromSkin(GameData.instance.selectedSkin);

    final scaledW = skin.srcSize.x * myScale;
    final scaledH = skin.srcSize.y * myScale;
    final dX = (skin.srcSize.x - scaledW) / 2;
    final dY = (skin.srcSize.y - scaledH) / 2;

    final drawX = -(skin.srcSize.x - size.x) / 2 + dX;
    final drawY = -(shouldFlip ? (skin.srcSize.y - size.y) : 0.0) + dY;
    final renderRect = Rect.fromLTWH(0, 0, scaledW, scaledH);

    c.save();
    c.translate(drawX, drawY);

    if (jetpack) {
      final dy = shouldFlip ? height : 0.0;
      jetpackAnimation!.getSprite().render(c, position: Vector2(-1, dy));
    }

    if (angle == 0) {
      c.translate(0, renderRect.height / 2);
      c.scale(1.0, 1.0 * (shouldFlip ? 1.0 : -1.0));
      c.translate(0, -renderRect.height / 2);
    } else {
      c.translate(renderRect.width / 2, renderRect.height / 2);
      c.rotate(angle);
      c.translate(-renderRect.width / 2, -renderRect.height / 2);
    }
    skin.renderRect(c, renderRect, overridePaint: _paint);
    c.restore();

    renderParticles(c);

    if (DEBUG) {
      c.drawRect(
        getCurrentRect(),
        Palette.playerDebugRect.paint()..style = PaintingStyle.stroke,
      );
    }
  }

  void renderParticles(Canvas c) {
    c.save();
    c.translate(0, shouldFlip ? 0 : -BLOCK_SIZE);
    particles.render(c, renderParticles: !jetpack);
    c.restore();
  }

  void shine() {
    shinyTimer = SHINE_TIMER;
  }

  void suck(Vector2 center) {
    suctionCenter = center;
    jetpackTimeout = 0.0;
  }

  void boost() {
    hovering = false;
    if (pulserJetpack) {
      speedY -= gameRef.gravity.sign * 300;
    }
    particles.jetpackBoost();
    jetpackAnimation?.reset();
  }

  void hoverStart() {
    hovering = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.sleeping) {
      hurtTimer = shinyTimer = 0.0;
      return;
    }

    if (hurt) {
      hurtTimer -= dt;
    }
    if (shiny) {
      shinyTimer -= dt;
    }
    if (invulnerable) {
      invulnerabilityTimer -= dt;
    }
    if (jetpack) {
      jetpackTimeout -= dt;
      jetpackAnimation!.update(dt);
    }
    if (!jetpack) {
      hovering = false;
    }

    if (suctionCenter != null) {
      final isThereYet = moveToCenter(suctionCenter!, SUCTION_SPEED, dt);
      if (myScale == 0.001) {
        gameRef.gameOver();
      } else if (isThereYet) {
        myScale -= dt;
        myScale = myScale.clamp(0.001, 1.0);

        angle += dt;
      }

      return;
    }

    particles.update(dt);
    updatePosition(dt);
  }

  void updatePosition(double dt) {
    x += dt * PLAYER_SPEED;

    final blockRect = getCurrentRect();

    if (!invulnerable && (y < blockRect.top || y > blockRect.bottom - height)) {
      livesLeft--;
      Rumble.rumble();
      if (livesLeft > 0) {
        hurtTimer = HURT_TIMER;
      } else {
        // save the death dt so that we can skip one update
        // if the player gets an extra life
        deathDt = dt;
        x -= dt * PLAYER_SPEED; // rollback
        gameRef.gameOver();
        return;
      }
    }

    double accY;
    if (regularJetpack) {
      accY = (hovering ? -0.3 : 1) * gameRef.gravity;
    } else if (pulserJetpack) {
      accY = 0.5 * gameRef.gravity;
    } else {
      accY = gameRef.gravity;
    }
    y += accY * dt * dt / 2 + speedY * dt;
    speedY += accY * dt;

    if (y < blockRect.top) {
      y = blockRect.top;
      speedY = 0;
    } else if (y > blockRect.bottom - height) {
      y = blockRect.bottom - height;
      speedY = 0;
    }
  }

  Rect getCurrentRect() {
    return gameRef.world.children
        .whereType<Background>()
        .firstWhere((c) => c.containsX(right))
        .findRectContaining(right);
  }

  double get right => x + width;

  @override
  int get priority => 5;

  Vector2 toCenter() => toRect().center.toVector2();

  // maybe abstract to position component?
  bool moveToCenter(
    Vector2 goal,
    double speed,
    double dt, {
    double threshold = 0.001,
  }) {
    if (goal.x - width / 2 == x && goal.y - height / 2 == y) {
      return true;
    }

    final displacement = toCenter() - goal;
    final prevDist = displacement.length;
    if (prevDist < threshold) {
      x = goal.x - width / 2;
      y = goal.y - height / 2;
      return true;
    }

    final delta = displacement..scaleTo(speed * dt);
    x += delta.x;
    y += delta.y;

    final newDist = (toCenter() - goal).length;
    if (newDist < threshold || newDist > prevDist) {
      // right there or overshoot, correct
      x = goal.x - width / 2;
      y = goal.y - height / 2;
      return true;
    }

    return false;
  }
}

class PlayerCameraFollower extends ReadOnlyPositionProvider {
  final MyGame game;
  final Player player;

  final Vector2 _position = Vector2.zero();

  PlayerCameraFollower({
    required this.game,
    required this.player,
  });

  @override
  Vector2 get position {
    _position.x = player.position.x - game.size.x / 3;
    return _position;
  }
}
