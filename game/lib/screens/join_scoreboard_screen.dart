import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/scoreboard.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/gr_container.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/palette.dart';

class JoinScoreboardScreen extends StatefulWidget {
  const JoinScoreboardScreen({super.key});

  @override
  JoinScoreboardScreenState createState() => JoinScoreboardScreenState();
}

class JoinScoreboardScreenState extends State<JoinScoreboardScreen> {
  final playerIdTextController = TextEditingController();

  String _status = '';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    playerIdTextController.dispose();
    super.dispose();
  }

  Future<bool> _checkPlayerIdAvailability() async {
    if (playerIdTextController.text.isEmpty) {
      setState(() => _status = 'Player id cannot be empty');
      return false;
    }

    setState(() => _status = 'Checking...');

    try {
      final isPlayerIdAvailable = !CHECK_PLAYER_ID ||
          await ScoreBoard.isPlayerIdAvailable(playerIdTextController.text);

      setState(() {
        _status = isPlayerIdAvailable
            ? 'Player id available'
            : 'Player id already in use';
      });

      return isPlayerIdAvailable;
    } on Exception catch (_) {
      setState(() => _status = 'Error');
    }

    return false;
  }

  Future<void> _join() async {
    final isPlayerIdAvailable = await _checkPlayerIdAvailability();

    final highScore = GameData.instance.highScore;
    if (isPlayerIdAvailable && highScore != null) {
      await GameData.instance.setPlayerId(playerIdTextController.text);
      await ScoreBoard.submitScore(
        highScore,
        forceSubmission: true,
      );

      Navigator.pushReplacementNamed(context, '/scoreboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: MyGame()),
        joinScoreboard(context),
      ],
    );
  }

  Widget joinScoreboard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GRContainer(
          width: 500,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Label(
                label: 'Choose your player ID:',
                fontSize: 22,
                fontColor: PaletteColors.pinks.light,
              ),
              Container(
                width: 400,
                child: TextField(
                  controller: playerIdTextController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: PaletteColors.blues.light,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: PaletteColors.blues.light,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Quantum',
                    color: PaletteColors.blues.light,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Label(
                label:
                    '''By joining the scoreboard you agree that we collect your score,
your selected player skin and the chosen player id on the field above.
This information is only used for the display of the scoreboard.
                      ''',
                fontColor: PaletteColors.blues.light,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Column(
          children: [
            Label(
              label: _status,
              fontColor: PaletteColors.pinks.light,
            ),
            SecondaryButton(
              label: 'Check availability',
              onPress: _checkPlayerIdAvailability,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(
                  label: 'Join',
                  onPress: _join,
                ),
                SecondaryButton(
                  label: 'Cancel',
                  onPress: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
