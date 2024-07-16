import 'package:dio/dio.dart';
import 'package:flame/flame.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/skin.dart';

// does not work rn
const ENABLE_SCOREBOARD = false;

Skin parseSkin(String value) {
  return Skin.values.firstWhere((h) => h.toString() == value);
}

class ScoreBoardEntry {
  final String playerId;
  final int score;
  final Skin skin;

  ScoreBoardEntry({
    required this.playerId,
    required this.score,
    required this.skin,
  });

  ScoreBoardEntry.fromJson(Map<String, dynamic> json)
      : this(
          skin: parseSkin(json['metadata'] as String),
          score: (json['score'] as double).toInt(),
          playerId: json['playerId'] as String,
        );
}

class ScoreBoard {
  static String? uuid;
  static const String host = 'https://api.score.fireslime.xyz';

  static Future<String> getUuid() async {
    return uuid ??=
        (await Flame.assets.readFile('firescore_uuid')).replaceAll('\n', '');
  }

  static Future<List<ScoreBoardEntry>> fetchScoreboard() async {
    if (!ENABLE_SCOREBOARD) {
      return [];
    }
    final uuid = await getUuid();
    final resp = await Dio().get<List>('$host/scores/$uuid?sortOrder=DESC');

    final data = resp.data;
    if (data is List<Map<String, dynamic>>) {
      return data.map(ScoreBoardEntry.fromJson).toList();
    }

    return [];
  }

  static Future<bool> isPlayerIdAvailable(String playerId) async {
    if (!ENABLE_SCOREBOARD) {
      return false;
    }

    final uuid = await getUuid();
    final resp = await Dio()
        .get<List>('$host/scores/$uuid?sortOrder=DESC&playerId=$playerId');

    final data = resp.data;

    if (data is List) {
      return data.isEmpty;
    }

    throw 'Could not check player id availability';
  }

  static Future<void> submitScore(
    int score, {
    bool forceSubmission = false,
  }) async {
    final data = GameData.instance;
    final lastSubmittedScore = data.highScore;

    await data.addScore(score);

    if (!ENABLE_SCOREBOARD) {
      return;
    }

    if (forceSubmission ||
        lastSubmittedScore == null ||
        score > lastSubmittedScore) {
      // Get the token
      final uuid = await getUuid();
      final tokenResponse = await Dio().get<Map>('$host/scores/token/$uuid');
      final token = tokenResponse.data?['token'] as String;

      final playerId = data.playerId;

      if (playerId != null) {
        final submitResponse = await Dio().put<void>(
          '$host/scores',
          data: {
            'playerId': playerId,
            'score': score,
            'metadata': data.selectedSkin.toString(),
          },
          options: Options(
            headers: <String, String>{'Authorization': 'Bearer $token'},
          ),
        );

        if (submitResponse.statusCode != 204) {
          print(submitResponse);
          throw 'Could not submit the score';
        }
      }
    }
  }
}
