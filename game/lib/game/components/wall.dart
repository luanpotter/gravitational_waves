import 'dart:ui';

import 'package:dartlin/dartlin.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:gravitational_waves/game/assets/tileset.dart';
import 'package:gravitational_waves/game/collections.dart';
import 'package:gravitational_waves/game/components/revamped/broken_glass.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:gravitational_waves/game/util.dart';

class Wall extends PositionComponent with HasGameRef<MyGame> {
  static final Paint _wall = Palette.wall.paint();

  Map<int, int> brokenPanes = {};

  Sprite get wallSprite => Tileset.wall;
  double get w => wallSprite.srcSize.x;
  double get h => wallSprite.srcSize.y;

  double get startY => (gameRef.size.y - h) / 2;

  int currentStartingPane = 0;

  Wall(double x) {
    this.x = x;
    y = 0;
  }

  @override
  void render(Canvas c) {
    renderColorBg(c);
    renderWall(c);
    super.render(c);
  }

  void renderColorBg(Canvas c) {
    c.renderAt(gameRef.camera.viewfinder.position - position, (c) {
      final topBar = Rect.fromLTWH(
        -gameRef.size.x / 2,
        0.0,
        2 * gameRef.size.x,
        startY,
      );
      final bottomBar = Rect.fromLTWH(
        -gameRef.size.x / 2,
        (gameRef.size.y + h) / 2,
        2 * gameRef.size.x,
        startY,
      );
      c.drawRect(topBar, _wall);
      c.drawRect(bottomBar, _wall);
    });
  }

  void renderWall(Canvas c) {
    var dx = 0.0;
    var currentPane = currentStartingPane;
    while (dx < gameRef.cameraX + gameRef.size.x + w - x) {
      final brokenType = brokenPanes[currentPane];

      final sprite =
          brokenType != null ? Tileset.brokenWalls[brokenType] : wallSprite;
      sprite.render(c, position: Vector2(dx, startY), size: Vector2(w, h));

      dx += w;
      currentPane++;
    }
  }

  @override
  void update(double t) {
    super.update(t);
    if (x + gameRef.size.x < gameRef.player.x - gameRef.size.x) {
      final panesToMove = gameRef.size.x ~/ w;
      x += panesToMove * w;
      currentStartingPane += panesToMove;
    }
    brokenPanes.removeWhere((key, value) => currentStartingPane - 1 > key);
  }

  void spawnBrokenGlass({required bool before, int number = 1}) {
    final startingPane = currentStartingPane + (gameRef.player.x - x) ~/ w;
    final numberOfPanes = before ? 4 : gameRef.size.x ~/ w;
    final sign = before ? -1 : 1;

    final newBrokenPanes = List<int>.generate(numberOfPanes, (e) => e)
        .shuffled()
        .map((e) => startingPane + sign * e)
        .where((e) => !brokenPanes.containsKey(e))
        .take(number)
        .associateWith((_) => Tileset.brokenWalls.randomIdx(R));

    newBrokenPanes.forEach((paneIdx, brokenType) {
      final delta = Tileset.brokenWallDeltas[brokenType];
      final dx = x + (paneIdx - currentStartingPane) * w + delta.key;
      final dy = startY + delta.value;
      gameRef.add(BrokenGlass(dx, dy));
    });

    if (newBrokenPanes.isNotEmpty) {
      gameRef.vibrate();
    }

    brokenPanes.addAll(newBrokenPanes);
  }

  @override
  int get priority => 2;
}
