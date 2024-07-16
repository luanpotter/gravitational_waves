import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/gr_container.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/palette.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: MyGame()),
        Column(
          children: [
            const SizedBox(height: 40),
            Label(
              label: 'Credits',
              fontSize: 28,
              fontColor: PaletteColors.blues.light,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GRContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/fireslime-banner.png',
                            width: 200,
                          ),
                          Label(
                            label: 'Game made by Fireslime',
                            fontSize: 18,
                            fontColor: PaletteColors.blues.light,
                          ),
                          const Link(
                            link: 'https://fireslime.xyz',
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GRContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Label(
                            label: 'Music by ©2019 Joshua McLean',
                            fontSize: 16,
                            fontColor: PaletteColors.blues.light,
                          ),
                          Label(
                            label: 'Licensed under CC BY 4.0',
                            fontSize: 16,
                            fontColor: PaletteColors.blues.light,
                          ),
                          const Link(
                            link: 'http://mrjoshuamclean.com',
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SecondaryButton(
              label: 'Back',
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }
}
