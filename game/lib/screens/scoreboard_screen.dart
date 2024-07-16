import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/assets/char.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/scoreboard.dart';
import 'package:gravitational_waves/widgets/button.dart';
import 'package:gravitational_waves/widgets/label.dart';
import 'package:gravitational_waves/widgets/palette.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  ScoreboardScreenState createState() => ScoreboardScreenState();
}

class ScoreboardScreenState extends State<ScoreboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: MyGame()),
        scoreboard(context),
      ],
    );
  }

  Widget scoreboard(BuildContext context) {
    return Align(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Label(
                  label: 'Scoreboard',
                  fontColor: PaletteColors.blues.light,
                  fontSize: 36,
                ),
                if (!ENABLE_SCOREBOARD)
                  Label(
                    label: 'Scoreboard is disabled for this build.',
                    fontColor: PaletteColors.blues.light,
                    fontSize: 24,
                  )
                else
                  FutureBuilder(
                    future: Future.wait([
                      ScoreBoard.fetchScoreboard(),
                    ]),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          {
                            return Center(
                              child: Label(label: 'Loading results...'),
                            );
                          }
                        case ConnectionState.done:
                          {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(
                                child:
                                    Label(label: 'Could not fetch scoreboard.'),
                              );
                            }
                            final data = snapshot.data as List;
                            return showScoreboard(
                              context,
                              GameData.instance.playerId,
                              data[0] as List<ScoreBoardEntry>,
                            );
                          }
                      }
                    },
                  ),
                PrimaryButton(
                  label: 'Back',
                  onPress: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showScoreboard(
    BuildContext context,
    String? playerId,
    List<ScoreBoardEntry>? entries,
  ) {
    Color fontColor(ScoreBoardEntry entry) => entry.playerId == playerId
        ? PaletteColors.pinks.dark
        : PaletteColors.blues.light;

    final list = ListView(
      padding: const EdgeInsets.all(10),
      children: (entries ?? []).asMap().entries.map((entry) {
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
          color: entry.value.playerId == playerId
              ? PaletteColors.pinks.light
              : PaletteColors.blues.dark,
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 5),
                    SpriteWidget(
                      sprite: Char.fromSkin(entry.value.skin),
                      // TODO(luan): figure out sprite widget size
                      // srcSize: Vector2(60.0, 40.0),
                    ),
                    Label(
                      fontColor: fontColor(entry.value),
                      label: '#${entry.key + 1}',
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Label(
                        label: entry.value.playerId,
                        fontSize: 14,
                        fontColor: fontColor(entry.value),
                      ),
                      const SizedBox(width: 20),
                      Label(
                        label: '${entry.value.score}',
                        fontSize: 14,
                        fontColor: fontColor(entry.value),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (playerId == null) {
      return Flexible(
        child: Column(
          children: [
            SecondaryButton(
              label: 'Join the scoreboard',
              onPress: () =>
                  Navigator.pushReplacementNamed(context, '/join-scoreboard'),
            ),
            Expanded(child: list),
          ],
        ),
      );
    } else {
      return Flexible(child: list);
    }
  }
}
