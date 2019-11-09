import 'dart:ui';

import 'package:flame/palette.dart';

class Palette extends BasicPalette {
  static const PaletteEntry black = BasicPalette.black;

  static const PaletteEntry menuBg = BasicPalette.black;
  static const PaletteEntry menuItems = BasicPalette.white;
  static const PaletteEntry menuTitleText = BasicPalette.white;
  static const PaletteEntry menuItemsText = BasicPalette.black;
  static const PaletteEntry livesCounter = const PaletteEntry(const Color(0xFF0000FF));

  static const PaletteEntry player = const PaletteEntry(const Color(0xFFFFFF00));
  static const PaletteEntry playerShine = const PaletteEntry(const Color(0x88FFFF00));
  static const PaletteEntry playerDebugRect = const PaletteEntry(const Color(0xFFFF2266));
}