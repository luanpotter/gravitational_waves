// NOTE: this is a development file to test widgets in isolation
// ignore: depend_on_referenced_packages
import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/widgets/assets/ui_tileset.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/game_over.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/spritesheet_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UITileset.init();
  final dashbook = Dashbook();

  dashbook
      .storiesOf('Button')
      .decorator(CenterDecorator())
      .add('default', (_) => Button(label: 'Play', onPress: () {}))
      .add('primary', (_) => PrimaryButton(label: 'Play', onPress: () {}))
      .add('secondary', (_) => SecondaryButton(label: 'Play', onPress: () {}));

  dashbook.storiesOf('SpritesheetContainer').decorator(CenterDecorator()).add(
        'default',
        (ctx) => Container(
          width: ctx.numberProperty('width', 100),
          height: ctx.numberProperty('height', 100),
          child: SpritesheetContainer(
            spriteSheet: UITileset.tileset,
            tileSize: 16,
            destTileSize: 50,
            child: Center(child: Label(label: 'Cool label')),
          ),
        ),
      );

  dashbook.storiesOf('GameOver').decorator(CenterDecorator()).add(
        'default',
        (_) => GameOverContainer(
          distance: 100,
          gems: 20,
          showExtraLifeButton: true,
          playAgain: () {},
          goToMainMenu: () {},
          extraLife: () {},
        ),
      );

  runApp(dashbook);
}
