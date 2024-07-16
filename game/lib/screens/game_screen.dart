import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/ads.dart';
import 'package:gravitational_waves/game/audio.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/game_over.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/slide_in_container.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return GameScreenState();
  }
}

class GameScreenState extends State<GameScreen> {
  MyGame? game;
  bool _playing = false;
  bool _playSection = false;
  bool _showGameOver = false;
  bool _adLoading = false;

  @override
  void initState() {
    super.initState();
    game = setupGame();
  }

  MyGame setupGame() {
    final game = MyGame();
    game.backToMenu = () => setState(() => _playing = false);
    game.showGameOver = (bool show) {
      setState(() => _showGameOver = show);
    };
    return game;
  }

  void startGame({required bool enablePowerups}) {
    game!.start(enablePowerups: enablePowerups);

    setState(() {
      _playSection = false;
      _playing = true;
    });
  }

  Future<void> handleExtraLife() async {
    if (game!.hasUsedExtraLife) {
      print('You already used your extra life.');
      return;
    }
    setState(() => _adLoading = true);
    final result = await Ads.showAd();
    if (result) {
      game!.gainExtraLife();
    }
    setState(() => _adLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final game = this.game;
    if (game == null) {
      return Container();
    }

    final children = <Widget>[];

    children.add(GameWidget(game: game));

    if (_showGameOver) {
      children.add(
        Center(
          child: SlideInContainer(
            from: const Offset(0.0, 1.5),
            duration: const Duration(milliseconds: 500),
            child: _adLoading
                ? const GameOverLoadingContainer()
                : GameOverContainer(
                    distance: game.score,
                    gems: game.coins,
                    showExtraLifeButton:
                        !game.hasUsedExtraLife && Ads.adLoaded(),
                    goToMainMenu: () {
                      setState(() {
                        _showGameOver = false;
                        _playing = false;
                        game.preStart();
                        Audio.menuMusic();
                      });
                    },
                    playAgain: () {
                      setState(() {
                        _showGameOver = false;
                        game.restart();
                      });
                    },
                    extraLife: handleExtraLife,
                  ),
          ),
        ),
      );
    }

    if (!_playing) {
      final sectionChildren = <Widget>[];

      if (_playSection) {
        sectionChildren.addAll([
          SlideInContainer(
            from: const Offset(-2.0, 0.0),
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Classic',
                  onPress: () => startGame(enablePowerups: false),
                ),
                PrimaryButton(
                  label: ENABLE_REVAMP ? 'Revamped' : 'Revamped (Soon)',
                  onPress: ENABLE_REVAMP
                      ? () => startGame(enablePowerups: true)
                      : null,
                ),
                SecondaryButton(
                  label: 'Back',
                  onPress: () => setState(() => _playSection = false),
                ),
              ],
            ),
          ),
        ]);
      } else {
        sectionChildren.addAll([
          Label(
            label: [
              'Total Gems: ${GameData.instance.coins}',
              'High Score: ${GameData.instance.highScore ?? '-'}',
            ].join(' | '),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                label: 'Play',
                onPress: () {
                  setState(() => _playSection = true);
                },
              ),
              SecondaryButton(
                label: 'Options',
                onPress: () => Navigator.of(context).pushNamed('/options'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SecondaryButton(
                label: 'Skins',
                onPress: () => Navigator.of(context).pushNamed('/skins'),
              ),
              SecondaryButton(
                label: 'Scoreboard',
                onPress: () => Navigator.of(context).pushNamed('/scoreboard'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SecondaryButton(
                label: 'Credits',
                onPress: () => Navigator.of(context).pushNamed('/credits'),
              ),
              if (!kIsWeb)
                SecondaryButton(
                  label: 'Quit',
                  onPress: () => exit(0),
                ),
            ],
          ),
        ]);
      }

      children.add(
        Align(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: SlideInContainer(
                  from: const Offset(0.0, -1.5),
                  child: Image.asset('assets/images/game-logo.png', width: 400),
                ),
              ),
              Expanded(
                child: SlideInContainer(
                  from: const Offset(0.0, 1.5),
                  child: Column(
                    children: sectionChildren,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(children: children);
  }
}
