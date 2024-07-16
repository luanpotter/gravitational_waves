import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:gravitational_waves/game/palette.dart';
import 'package:gravitational_waves/game/util.dart';

class PauseOverlay {
  static final Paint _filled = Palette.hud.paint()..strokeWidth = 4.0;
  static final Paint _hollow = Palette.hud.paint()
    ..strokeWidth = 6.0
    ..style = PaintingStyle.stroke;

  static void render(Canvas c, Vector2 size, {required bool showMessage}) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.x, size.y), _hollow);

    final xOffset = size.x - 8.0;
    const yOffset = 8.0;
    c.drawRect(Rect.fromLTWH(xOffset - 14.0, yOffset, 4.0, 18.0), _filled);
    c.drawRect(Rect.fromLTWH(xOffset - 4.0, yOffset, 4.0, 18.0), _filled);

    if (showMessage) {
      final p = Vector2(size.x / 2, size.y / 2);
      Fonts.tutorial.render(c, 'Tap to resume', p, anchor: Anchor.center);
    }
  }
}
