import 'package:flutter/material.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/gr_container.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/palette.dart';

class _Line extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;

  const _Line(this.leftLabel, this.rightLabel);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Label(
            label: leftLabel,
            fontSize: 22,
            fontColor: PaletteColors.blues.dark,
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Label(
            label: rightLabel,
            fontSize: 22,
            fontColor: PaletteColors.blues.light,
          ),
        ),
      ],
    );
  }
}

class GameOverContainer extends StatelessWidget {
  static const WIDTH = 350.0;
  static const HEIGHT = 320.0;

  final int distance;
  final int gems;
  final bool showExtraLifeButton;
  final void Function() goToMainMenu;
  final void Function() playAgain;
  final void Function() extraLife;

  const GameOverContainer({
    required this.distance,
    required this.gems,
    required this.showExtraLifeButton,
    required this.goToMainMenu,
    required this.playAgain,
    required this.extraLife,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GRContainer(
      width: WIDTH,
      height: HEIGHT,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Label(
            label: 'Game Over',
            fontSize: 36,
            fontColor: PaletteColors.blues.dark,
          ),
          const SizedBox(height: 20),
          _Line('Gems', '$gems'),
          _Line('Distance', '$distance'),
          const SizedBox(height: 20),
          if (showExtraLifeButton)
            PrimaryButton(
              label: 'Extra life (ad)',
              onPress: extraLife,
            ),
          PrimaryButton(label: 'Play again', onPress: playAgain),
          SecondaryButton(label: 'Back to menu', onPress: goToMainMenu),
        ],
      ),
    );
  }
}

class GameOverLoadingContainer extends StatelessWidget {
  const GameOverLoadingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const GRContainer(
      width: GameOverContainer.WIDTH,
      height: GameOverContainer.HEIGHT,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
