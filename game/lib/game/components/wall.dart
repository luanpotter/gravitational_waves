import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import '../game.dart';

import '../palette.dart';
import '../assets/tileset.dart';
import '../util.dart';
import '../collections.dart';
import 'revamped/broken_glass.dart';

class Wall extends PositionComponent with Resizable, HasGameRef<MyGame> {
  static final Paint _wall = Palette.wall.paint;

  Map<int, int> brokenPanes = {};

  Sprite get wallSprite => Tileset.wall;
  double get w => wallSprite.size.x;
  double get h => wallSprite.size.y;

  double get startY => (size.height - h) / 2;

  int get currentStartingPane => (x + gameRef.camera.x) ~/ w;

  @override
  void render(Canvas c) {
    renderColorBg(c);
    renderWall(c);
  }

  void renderColorBg(Canvas c) {
    final topBar = Rect.fromLTWH(-size.width / 2, 0.0, 2 * size.width, startY);
    final bottomBar = Rect.fromLTWH(-size.width / 2, (size.height + h) / 2, 2 * size.width, startY);
    c.drawRect(topBar, _wall);
    c.drawRect(bottomBar, _wall);
  }

  void renderWall(Canvas c) {
    double dx = x;
    int currentPane = currentStartingPane;
    while (dx < size.width + w) {
      int brokenType = brokenPanes[currentPane];

      Sprite sprite = brokenType != null ? Tileset.brokenWalls[brokenType] : wallSprite;
      sprite.renderPosition(c, Position(dx, startY), size: Position(w, h));

      dx += w;
      currentPane++;
    }
  }

  @override
  void update(double t) {
    x = -w - (gameRef.player.x % w);
    brokenPanes.removeWhere((key, value) => currentStartingPane - 1 > key);
  }

  void spawnBrokenGlass(int number) {
    final currentRealX = x + gameRef.camera.x;
    final numberOfPanes = (size.width + w) ~/ w;
    Map<int, int> newBrokenPanes = List<int>
      .generate(numberOfPanes, (e) => e)
      .shuffled()
      .map((e) => currentStartingPane + e)
      .where((e) => !brokenPanes.containsKey(e))
      .take(number)
      .associate(valueMapper: (_) => Tileset.brokenWalls.randomIdx(R));
    
    newBrokenPanes.forEach((paneIdx, brokenType) {
      final delta = Tileset.brokenWallDeltas[brokenType];
      double dx = currentRealX + (paneIdx - currentStartingPane) * w + delta.first;
      double dy = startY + delta.second;
      gameRef.addLater(BrokenGlass(dx, dy));
    });

    brokenPanes.addAll(newBrokenPanes);
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 2;
}
