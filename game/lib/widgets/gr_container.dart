import 'package:flutter/widgets.dart';
import 'package:gravitational_waves/widgets/assets/ui_tileset.dart';
import 'package:gravitational_waves/widgets/spritesheet_container.dart';

class GRContainer extends StatelessWidget {
  final double? width;
  final double? height;

  final Widget child;

  final EdgeInsetsGeometry? padding;

  const GRContainer({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SpritesheetContainer(
      padding: padding,
      width: width,
      height: height,
      spriteSheet: UITileset.tileset,
      tileSize: 16,
      destTileSize: 30,
      child: child,
    );
  }
}
