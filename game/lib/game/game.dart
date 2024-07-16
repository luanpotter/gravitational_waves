import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:gravitational_waves/game/analytics.dart';
import 'package:gravitational_waves/game/audio.dart';
import 'package:gravitational_waves/game/collections.dart';
import 'package:gravitational_waves/game/components/background.dart';
import 'package:gravitational_waves/game/components/coin.dart';
import 'package:gravitational_waves/game/components/hud.dart';
import 'package:gravitational_waves/game/components/planet.dart';
import 'package:gravitational_waves/game/components/player.dart';
import 'package:gravitational_waves/game/components/revamped/powerups.dart';
import 'package:gravitational_waves/game/components/stars.dart';
import 'package:gravitational_waves/game/components/tutorial.dart';
import 'package:gravitational_waves/game/components/wall.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:gravitational_waves/game/pause_overlay.dart';
import 'package:gravitational_waves/game/rotation_manager.dart';
import 'package:gravitational_waves/game/rumble.dart';
import 'package:gravitational_waves/game/scoreboard.dart';
import 'package:gravitational_waves/game/spawner.dart';
import 'package:gravitational_waves/game/util.dart';

class MyGame extends FlameGame with TapDetector {
  static Spawner planetSpawner = Spawner(0.12);

  // Setup by the flutter components to allow this game instance
  // to callback to the flutter code and go back to the menu
  void Function()? backToMenu;

  // TODO(luan): reconsider this
  // ignore: avoid_positional_boolean_parameters
  void Function(bool)? showGameOver;

  late RotationManager rotationManager;
  late double lastGeneratedX;
  late double gravity;
  int coins = 0;
  bool hasUsedExtraLife = false;

  /* -1 : do not show, 0: show first, 1: show second */
  late int showTutorial;
  Tutorial? tutorial;

  bool sleeping = false;
  bool gamePaused = false;
  bool enablePowerups = false;

  late Player player;
  late Hud hud;
  late Wall wall;
  late Powerups powerups;

  double get cameraX => camera.viewfinder.position.x;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final screenSize = Vector2(32, 18) * BLOCK_SIZE;
    camera = CameraComponent.withFixedResolution(
      width: screenSize.x,
      height: screenSize.y,
      // TODO(luan): figure this out
      // noClip: true,
    );

    await preStart();
  }

  Future<void> preStart() async {
    final isFirstTime = GameData.instance.isFirstTime();

    sleeping = true;
    gamePaused = false;

    gravity = GRAVITY_ACC;
    const firstX = -CHUNK_SIZE / 2.0 * BLOCK_SIZE;
    lastGeneratedX = firstX;
    coins = 0;
    hasUsedExtraLife = false;

    world.clear();
    if (isFirstTime) {
      showTutorial = 0;
      await _addBg(Background.tutorial(lastGeneratedX));
    } else {
      showTutorial = -1;
      await _addBg(Background.plains(lastGeneratedX));
    }

    await world.addAll([
      powerups = Powerups(),
      player = Player(),
    ]);
    setupCamera();

    await world.add(wall = Wall(firstX - size.x));
    camera.backdrop = Stars();

    rotationManager = RotationManager();
  }

  void setupCamera() {
    camera.follow(
      PlayerCameraFollower(game: this, player: player),
    );
  }

  void start({
    required bool enablePowerups,
  }) {
    this.enablePowerups = enablePowerups;
    Analytics.log(
      enablePowerups ? EventName.START_REVAMPED : EventName.START_CLASSIC,
    );
    sleeping = false;
    camera.viewport.add(hud = Hud());
    powerups.reset();
    generateNextChunk();
    Audio.gameMusic();
  }

  Future<void> restart() async {
    await preStart();
    start(enablePowerups: enablePowerups);
  }

  Background findBackgroundForX(double x) {
    return children.whereType<Background>().firstWhere((e) => e.containsX(x));
  }

  Future<void> generateNextChunk() async {
    while (lastGeneratedX < player.x + size.x) {
      final bg = Background(lastGeneratedX);
      await _addBg(bg);

      final coinLevel = Coin.computeCoinLevel(
        x: lastGeneratedX,
        powerups: enablePowerups,
      );
      final amountCoins = R.nextInt(1 + coinLevel);
      final coins = <Coin>[];
      for (var i = 0; i < amountCoins; i++) {
        final spot = bg.findRectFor(bg.columns.randomIdx(R));
        final top = R.nextBool();
        final x = spot.center.dx;
        const yOffset = Coin.SIZE / 2;
        final y = top ? spot.top + yOffset : spot.bottom - yOffset;
        if (coins.any((c) => c.overlaps(x, y))) {
          continue;
        }
        final c = Coin(x, y);
        coins.add(c);
        await world.add(c);
      }
    }
  }

  Future<void> _addBg(Background bg) async {
    await world.add(bg);
    lastGeneratedX = bg.endX;
  }

  int get score => player.x ~/ 100;

  Future<void> doShowTutorial() async {
    pause();
    await camera.viewport.add(tutorial = Tutorial());
  }

  @override
  void update(double t) {
    if (gamePaused) {
      tutorial?.update(t);
      return;
    }

    super.update(t);

    if (showTutorial > -1 && player.x >= Tutorial.positions[showTutorial]) {
      doShowTutorial();
      showTutorial++;
      if (showTutorial > 1) {
        showTutorial = -1;
      }
    }

    if (!sleeping) {
      maybeGeneratePlanet(t);
      generateNextChunk();
      rotationManager.tick(t);
    }
  }

  void maybeGeneratePlanet(double dt) {
    planetSpawner.maybeSpawn(dt, () => camera.viewport.add(Planet()));
  }

  void gainExtraLife() {
    hasUsedExtraLife = true;
    player.extraLife();
    gamePaused = true;
    showGameOver?.call(false);
    sleeping = false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Vector2.zero() & canvasSize, Palette.background.paint());
    canvas.save();
    canvas.translate(canvasSize.x / 2, canvasSize.y / 2);
    canvas.rotate(rotationManager.angle);
    canvas.translate(-canvasSize.x / 2, -canvasSize.y / 2);
    super.render(canvas);
    canvas.restore();

    if (gamePaused) {
      final showMessage = tutorial == null;
      PauseOverlay.render(canvas, canvasSize, showMessage: showMessage);
    }
  }

  @override
  void onTapDown(TapDownInfo details) {
    if (player.regularJetpack) {
      player.hoverStart();
    }
  }

  @override
  void onTapUp(TapUpInfo details) {
    if (sleeping) {
      return;
    }
    if (gamePaused) {
      final isTutorial = tutorial != null;
      resume();
      if (!isTutorial) {
        return;
      }
    }
    super.onTapUp(details);
    if (showTutorial == 0) {
      showTutorial = -1; // if the player jumps don't show the tutorial
    }
    if (player.jetpack) {
      player.boost();
    } else {
      gravity *= -1;
    }
  }

  void pause() {
    Audio.pauseMusic();
    if (sleeping || gamePaused) {
      return;
    }
    gamePaused = true;
  }

  void resume() {
    tutorial?.removeFromParent();
    tutorial = null;
    gamePaused = false;
    Audio.resumeMusic();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);

    if (state != AppLifecycleState.resumed) {
      pause();
    } else {
      Audio.resumeMusic();
    }
  }

  Future<void> gameOver() async {
    Audio.die();
    Audio.stopMusic();

    GameData.instance.addCoins(coins);
    ScoreBoard.submitScore(score);

    sleeping = true;
    showGameOver?.call(true);
  }

  void collectCoin() {
    coins++;
    Audio.coin();
  }

  void vibrate() {
    Rumble.rumble();
    // TODO(luan): implement camera shake
    // camera.shake();
  }
}