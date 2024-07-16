import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spritesheet.g.dart';

const double _SRC_SIZE = 16.0;

@JsonSerializable()
class AnimationElement {
  final int x;
  final int y;
  final int w;
  final int h;
  final int length;
  final int millis;

  AnimationElement(this.x, this.y, this.w, this.h, this.length, this.millis);

  factory AnimationElement.fromJson(Map<String, dynamic> json) =>
      _$AnimationElementFromJson(json);

  Map<String, dynamic> toJson() => _$AnimationElementToJson(this);

  Sprite sprite(Image image) {
    final x = this.x * _SRC_SIZE;
    final y = this.y * _SRC_SIZE;
    final w = this.w * _SRC_SIZE;
    final h = this.h * _SRC_SIZE;
    return Sprite(
      image,
      srcPosition: Vector2(x, y),
      srcSize: Vector2(w, h),
    );
  }

  SpriteAnimation animation(Image image) {
    final x = this.x * _SRC_SIZE;
    final y = this.y * _SRC_SIZE;
    final w = this.w * _SRC_SIZE;
    final h = this.h * _SRC_SIZE;
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        texturePosition: Vector2(x, y),
        textureSize: Vector2(w, h),
        stepTime: millis / 1000,
      ),
    );
  }
}

@JsonSerializable()
class AnimationsJson {
  final Map<String, AnimationElement> animations;

  AnimationsJson(this.animations);

  factory AnimationsJson.fromJson(Map<String, dynamic> json) =>
      _$AnimationsJsonFromJson(json);
  Map<String, dynamic> toJson() => _$AnimationsJsonToJson(this);
}

class Spritesheet {
  final Image _image;
  final AnimationsJson _animations;

  Spritesheet._(this._image, this._animations);

  static Future<Spritesheet> parse(String fileName) async {
    final content = await Flame.assets.readJson('images/$fileName.json');
    final animations = AnimationsJson.fromJson(content);
    final image = await Flame.images.load('$fileName.png');
    return Spritesheet._(image, animations);
  }

  SpriteAnimation animation(String name) {
    return _animations.animations[name]!.animation(_image);
  }

  Sprite sprite(String name) {
    return _animations.animations[name]!.sprite(_image);
  }

  Sprite blockGn(String name, int dx, int dy) {
    final animation = _animations.animations[name]!;
    final x = (animation.x + dx) * _SRC_SIZE;
    final y = (animation.y + dy) * _SRC_SIZE;
    return Sprite(
      _image,
      srcPosition: Vector2(x, y),
      srcSize: Vector2.all(_SRC_SIZE),
    );
  }

  List<Sprite> generate(String name) {
    final list = <Sprite>[];
    var i = 1;
    while (true) {
      final key = '$name-$i';
      if (!_animations.animations.containsKey(key)) {
        break;
      }
      list.add(sprite(key));
      i++;
    }
    return list;
  }
}
