import 'dart:ui';

import 'package:dartlin/collections.dart';
import 'package:flame/components.dart';
import 'package:gravitational_waves/game/assets/tileset.dart';
import 'package:gravitational_waves/game/column.dart';
import 'package:gravitational_waves/game/components/tutorial.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:gravitational_waves/game/util.dart';

class Background extends PositionComponent with HasGameRef<MyGame> {
  static final Paint _bg = Palette.background.paint();

  late final List<Column> columns;

  Background(double x) {
    this.x = x;
    columns = _generateChunk(CHUNK_SIZE).toList();
  }

  Background.plains(double x) {
    this.x = x;
    columns = _generatePlains(CHUNK_SIZE).toList();
  }

  Background.tutorial(double x) {
    this.x = x;
    columns = Tutorial.generateTerrain().toList();
  }

  static Iterable<Column> _generatePlains(int size) {
    return List.generate(size, (_) => Column(0, 0));
  }

  static Iterable<Column> _generateChunk(int size) sync* {
    int? beforeTop;
    int? beforeBottom;

    var changesTop = 0;
    var changesBottom = 0;

    for (var i = 0; i < size; i++) {
      if (i < 3 || i >= size - 3) {
        yield Column(0, 0);
      } else {
        final nextForcedZero = (i + 1) >= size - 3;
        if (beforeTop == null || (changesTop / 2 * R.nextDouble() > 0.9)) {
          beforeTop = nextForcedZero ? 0 : R.nextInt(3);
          changesTop = 0;
        } else {
          changesTop++;
        }
        if (beforeBottom == null ||
            (changesBottom / 2 * R.nextDouble() > 0.9)) {
          beforeBottom = nextForcedZero ? 0 : R.nextInt(3);
          changesBottom = 0;
        } else {
          changesBottom++;
        }
        yield Column(beforeTop, beforeBottom);
      }
    }
  }

  double get startX => x;
  double get endX => x + BLOCK_SIZE * columns.length;

  bool containsX(double targetX) {
    return targetX >= startX && targetX < endX;
  }

  void drawBg(Canvas c, double x, double y, double w, double h) {
    c.drawRect(Rect.fromLTWH(x, y, w, h), _bg);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    columns.asMap().forEach((i, column) {
      final before = columns.getOrNull(i - 1) ?? column;
      final after = columns.getOrNull(i + 1) ?? column;
      final px = i * BLOCK_SIZE;

      final ddy = gameRef.size.y;
      drawBg(c, px, -ddy, BLOCK_SIZE, column.topHeight + ddy);
      drawBg(
        c,
        px,
        gameRef.size.y - column.bottomHeight,
        BLOCK_SIZE,
        column.bottomHeight + ddy,
      );

      final bottomPy = gameRef.size.y - column.bottomHeight;
      final bottomSet = Tileset.variant(column.bottomVariant);
      if (before.bottom < column.bottom) {
        final diff = column.bottom - before.bottom;
        bottomSet.renderOuter(c, OuterTilePosition.topLeft, px, bottomPy);
        for (var i = 1; i < diff; i++) {
          bottomSet.renderOuter(
            c,
            OuterTilePosition.left,
            px,
            bottomPy + i * BLOCK_SIZE,
          );
        }
        bottomSet.renderInner(
          c,
          InnerTilePosition.bottomRight,
          px,
          bottomPy + diff * BLOCK_SIZE,
        );
      } else if (after.bottom < column.bottom) {
        final diff = column.bottom - after.bottom;
        bottomSet.renderOuter(c, OuterTilePosition.topRight, px, bottomPy);
        for (var i = 1; i < diff; i++) {
          bottomSet.renderOuter(
            c,
            OuterTilePosition.right,
            px,
            bottomPy + i * BLOCK_SIZE,
          );
        }
        bottomSet.renderInner(
          c,
          InnerTilePosition.bottomLeft,
          px,
          bottomPy + diff * BLOCK_SIZE,
        );
      } else {
        bottomSet.renderOuter(c, OuterTilePosition.top, px, bottomPy);
      }

      final topPy = column.topHeight - BLOCK_SIZE;
      final topSet = Tileset.variant(column.topVariant);
      if (before.top < column.top) {
        final diff = column.top - before.top;
        topSet.renderOuter(c, OuterTilePosition.bottomLeft, px, topPy);
        for (i = 1; i < diff; i++) {
          topSet.renderOuter(
            c,
            OuterTilePosition.left,
            px,
            topPy - i * BLOCK_SIZE,
          );
        }
        topSet.renderInner(
          c,
          InnerTilePosition.topRight,
          px,
          topPy - diff * BLOCK_SIZE,
        );
      } else if (after.top < column.top) {
        final diff = column.top - after.top;
        topSet.renderOuter(c, OuterTilePosition.bottomRight, px, topPy);
        for (var i = 1; i < diff; i++) {
          topSet.renderOuter(
            c,
            OuterTilePosition.right,
            px,
            topPy - i * BLOCK_SIZE,
          );
        }
        topSet.renderInner(
          c,
          InnerTilePosition.topLeft,
          px,
          topPy - diff * BLOCK_SIZE,
        );
      } else {
        topSet.renderOuter(
          c,
          OuterTilePosition.bottom,
          px,
          topPy,
        );
      }
    });
    if (DEBUG) {
      renderDebug(c);
    }
  }

  void renderDebug(Canvas c) {
    c.drawRect(
      Rect.fromLTWH(startX, 0.0, endX - startX, gameRef.size.y),
      Paint()
        ..color = const Color(0xFFFF00FF)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (endX < gameRef.cameraX - gameRef.size.x) {
      removeFromParent();
    }
  }

  @override
  int get priority => 3;

  Rect findRectContaining(double targetX) {
    final idx = ((targetX - x) / BLOCK_SIZE).floor();
    return findRectFor(idx);
  }

  Rect findRectFor(int idx) {
    final column = columns[idx];
    final px = x + idx * BLOCK_SIZE;
    return Rect.fromLTWH(
      px,
      column.topHeight,
      BLOCK_SIZE,
      gameRef.size.y - column.topHeight - column.bottomHeight,
    );
  }
}
