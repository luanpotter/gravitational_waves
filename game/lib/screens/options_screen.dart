import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/preferences.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/gr_container.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/palette.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  OptionsScreenState createState() => OptionsScreenState();
}

class OptionsScreenState extends State<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: MyGame()),
        options(context),
      ],
    );
  }

  bool musicOn() => Preferences.instance.musicOn;

  bool soundOn() => Preferences.instance.soundOn;

  bool rumbleOn() => Preferences.instance.rumbleOn;

  Widget options(BuildContext context) {
    return Align(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Label(
              label: 'Options',
              fontSize: 82,
              fontColor: PaletteColors.blues.light,
            ),
          ),
          Expanded(
            child: GRContainer(
              padding: const EdgeInsets.all(10),
              width: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SecondaryButton(
                    label: 'Music ${musicOn() ? 'On' : 'Off'}',
                    onPress: () async {
                      await Preferences.instance.toggleMusic();
                      setState(() {});
                    },
                  ),
                  SecondaryButton(
                    label: 'Sound ${soundOn() ? 'On' : 'Off'}',
                    onPress: () async {
                      await Preferences.instance.toggleSounds();
                      setState(() {});
                    },
                  ),
                  SecondaryButton(
                    label: 'Rumble ${rumbleOn() ? 'On' : 'Off'}',
                    onPress: () async {
                      await Preferences.instance.toggleRumble();
                      setState(() {});
                    },
                  ),
                  PrimaryButton(
                    label: 'Back',
                    onPress: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
