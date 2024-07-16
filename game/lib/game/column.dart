import 'package:gravitational_waves/game/assets/tileset.dart';
import 'package:gravitational_waves/game/util.dart';

class Column {
  static const OFFSET = 5;

  int bottom;
  int top;
  late int bottomVariant;
  late int topVariant;

  Column(this.bottom, this.top) {
    bottomVariant = Tileset.randomVariant();
    topVariant = Tileset.randomVariant();
  }

  double get topHeight => BLOCK_SIZE * (OFFSET + top);
  double get bottomHeight => BLOCK_SIZE * (OFFSET + bottom);

  int randomY() => OFFSET + top + R.nextInt(8 - bottom - top);
  double randomYHeight() => BLOCK_SIZE * randomY();
}
