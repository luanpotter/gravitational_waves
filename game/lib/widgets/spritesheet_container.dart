import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart' as widgets;

class _Painter extends widgets.CustomPainter {
  final Image spriteSheet;
  final double tileSize;
  final double destTileSize;

  _Painter({
    required this.spriteSheet,
    required this.tileSize,
    required this.destTileSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final srcSize = Vector2.all(tileSize);
    final topLeftCorner = Sprite(
      spriteSheet,
      srcPosition: Vector2.zero(),
      srcSize: srcSize,
    );
    final topRightCorner = Sprite(
      spriteSheet,
      srcPosition: Vector2(tileSize * 2, 0),
      srcSize: srcSize,
    );

    final bottomLeftCorner = Sprite(
      spriteSheet,
      srcPosition: Vector2(0, 2 * tileSize),
      srcSize: srcSize,
    );
    final bottomRightCorner = Sprite(
      spriteSheet,
      srcPosition: Vector2(tileSize * 2, 2 * tileSize),
      srcSize: srcSize,
    );

    final topSide = Sprite(
      spriteSheet,
      srcPosition: Vector2(tileSize, 0),
      srcSize: srcSize,
    );
    final bottomSide = Sprite(
      spriteSheet,
      srcPosition: Vector2(tileSize, tileSize * 2),
      srcSize: srcSize,
    );

    final leftSide = Sprite(
      spriteSheet,
      srcPosition: Vector2(0, tileSize),
      srcSize: srcSize,
    );
    final rightSide = Sprite(
      spriteSheet,
      srcPosition: Vector2(tileSize * 2, tileSize),
      srcSize: srcSize,
    );

    final middle = Sprite(
      spriteSheet,
      srcPosition: Vector2.all(tileSize),
      srcSize: srcSize,
    );

    // Middle
    for (var y = destTileSize;
        y < size.height - destTileSize;
        y = y + destTileSize) {
      for (var x = destTileSize;
          x < size.width - destTileSize;
          x = x + destTileSize) {
        middle.renderRect(
          canvas,
          Rect.fromLTWH(x, y, destTileSize, destTileSize),
        );
      }
    }

    // Top and bottom side
    for (var i = destTileSize;
        i < size.width - destTileSize;
        i = i + destTileSize) {
      topSide.renderRect(
        canvas,
        Rect.fromLTWH(
          i,
          0,
          destTileSize,
          destTileSize,
        ),
      );
      bottomSide.renderRect(
        canvas,
        Rect.fromLTWH(
          i,
          size.height - destTileSize,
          destTileSize,
          destTileSize,
        ),
      );
    }

    // Left and right side
    for (var i = destTileSize;
        i < size.height - destTileSize;
        i = i + destTileSize) {
      leftSide.renderRect(
        canvas,
        Rect.fromLTWH(
          0,
          i,
          destTileSize,
          destTileSize,
        ),
      );
      rightSide.renderRect(
        canvas,
        Rect.fromLTWH(
          size.width - destTileSize,
          i,
          destTileSize,
          destTileSize,
        ),
      );
    }

    // Corners
    topLeftCorner.renderRect(
      canvas,
      Rect.fromLTWH(
        0,
        0,
        destTileSize,
        destTileSize,
      ),
    );
    topRightCorner.renderRect(
      canvas,
      Rect.fromLTWH(
        size.width - destTileSize,
        0,
        destTileSize,
        destTileSize,
      ),
    );

    bottomLeftCorner.renderRect(
      canvas,
      Rect.fromLTWH(
        0,
        size.height - destTileSize,
        destTileSize,
        destTileSize,
      ),
    );
    bottomRightCorner.renderRect(
      canvas,
      Rect.fromLTWH(
        size.width - destTileSize,
        size.height - destTileSize,
        destTileSize,
        destTileSize,
      ),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class SpritesheetContainer extends widgets.StatelessWidget {
  final widgets.Widget child;
  final Image spriteSheet;
  final double tileSize;
  final double destTileSize;

  final double? width;
  final double? height;
  final widgets.EdgeInsetsGeometry? padding;

  const SpritesheetContainer({
    required this.child,
    required this.spriteSheet,
    required this.tileSize,
    required this.destTileSize,
    super.key,
    this.width,
    this.height,
    this.padding,
  });

  @override
  widgets.Widget build(widgets.BuildContext context) {
    return widgets.Container(
      width: width,
      height: height,
      child: widgets.CustomPaint(
        painter: _Painter(
          spriteSheet: spriteSheet,
          tileSize: tileSize,
          destTileSize: destTileSize,
        ),
        child: widgets.Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
