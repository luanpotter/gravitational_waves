import 'package:dartlin/dartlin.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:gravitational_waves/game/assets/spritesheet.dart';
import 'package:gravitational_waves/game/collections.dart';
import 'package:gravitational_waves/game/util.dart';

enum OuterTilePosition {
  topLeft,
  top,
  topRight,
  left,
  center,
  right,
  bottomLeft,
  bottom,
  bottomRight
}

enum InnerTilePosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class BlockSet {
  late final Map<OuterTilePosition, Sprite> _outer;
  late final Map<InnerTilePosition, Sprite> _inner;

  BlockSet(Spritesheet sheet, int group) {
    Sprite outerGn(int dx, int dy) =>
        sheet.blockGn('back-group-$group', dx, dy);
    Sprite innerGn(int dx, int dy) => sheet.blockGn('corners-$group', dx, dy);
    _outer = {
      OuterTilePosition.topLeft: outerGn(0, 0),
      OuterTilePosition.top: outerGn(1, 0),
      OuterTilePosition.topRight: outerGn(2, 0),
      OuterTilePosition.left: outerGn(0, 1),
      OuterTilePosition.center: outerGn(1, 1),
      OuterTilePosition.right: outerGn(2, 1),
      OuterTilePosition.bottomLeft: outerGn(0, 2),
      OuterTilePosition.bottom: outerGn(1, 2),
      OuterTilePosition.bottomRight: outerGn(2, 2),
    };
    _inner = {
      InnerTilePosition.topLeft: innerGn(0, 0),
      InnerTilePosition.topRight: innerGn(1, 0),
      InnerTilePosition.bottomLeft: innerGn(0, 1),
      InnerTilePosition.bottomRight: innerGn(1, 1),
    };
  }

  void renderOuter(Canvas c, OuterTilePosition pos, double dx, double dy) {
    _outer[pos]!.render(c, position: Vector2(dx, dy));
  }

  void renderInner(Canvas c, InnerTilePosition pos, double dx, double dy) {
    _inner[pos]!.render(c, position: Vector2(dx, dy));
  }
}

class Tileset {
  static late final Spritesheet _sheet;

  static late final List<BlockSet> blocks;

  static late final Sprite wall;
  static late final List<Sprite> brokenWalls;
  static const List<Pair<int, int>> brokenWallDeltas = [
    Pair(3 * BLOCK_SIZE_INT, 2 * BLOCK_SIZE_INT),
    Pair(1 * BLOCK_SIZE_INT, 3 * BLOCK_SIZE_INT),
  ];

  static late final List<Sprite> planets;
  static late final List<Sprite> stars;

  static Future init() async {
    _sheet = await Spritesheet.parse('tileset');

    wall = _sheet.sprite('wall-pattern');
    brokenWalls = _sheet.generate('broken-wall-pattern');

    blocks = [1, 2].map((i) => BlockSet(_sheet, i)).toList();
    planets = _sheet.generate('back-props');
    stars = _sheet.generate('stars-pattern');
  }

  static BlockSet variant(int variant) {
    return blocks[variant];
  }

  static int randomVariant() {
    return blocks.randomIdx(R);
  }

  Sprite sprite(String name) {
    return _sheet.sprite(name);
  }
}
