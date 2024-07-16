import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, kIsWeb;
import 'package:flutter/material.dart';
import 'package:gravitational_waves/game/ads.dart';
import 'package:gravitational_waves/game/analytics.dart';
import 'package:gravitational_waves/game/assets/char.dart';
import 'package:gravitational_waves/game/assets/poofs.dart';
import 'package:gravitational_waves/game/assets/tileset.dart';
import 'package:gravitational_waves/game/audio.dart';
import 'package:gravitational_waves/game/game_data.dart';
import 'package:gravitational_waves/game/preferences.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:gravitational_waves/screens/credits_screen.dart';
import 'package:gravitational_waves/screens/game_screen.dart';
import 'package:gravitational_waves/screens/join_scoreboard_screen.dart';
import 'package:gravitational_waves/screens/options_screen.dart';
import 'package:gravitational_waves/screens/scoreboard_screen.dart';
import 'package:gravitational_waves/screens/skins_screen.dart';
import 'package:gravitational_waves/widgets/assets/ui_tileset.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  print('Starting app...');

  WidgetsFlutterBinding.ensureInitialized();

  if (ENABLE_FIREBASE) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAwyHBokdzuZcW_iQ6hu_7DCrP6_DclSqg',
        authDomain: 'fireslime-gravity-runner.firebaseapp.com',
        databaseURL: 'https://fireslime-gravity-runner.firebaseio.com',
        projectId: 'fireslime-gravity-runner',
        storageBucket: 'fireslime-gravity-runner.appspot.com',
        messagingSenderId: '107315711863',
        appId: '1:107315711863:web:1c84176903b93eb824db72',
        measurementId: 'G-E1SGKDJLF4',
      ),
    );
  }

  await setMobileOrientation();

  final setup = Future.wait([
    Preferences.init(),
    GameData.init(),
  ]).then((_) {
    return Future.wait([
      Audio.init(),
      Ads.init(),
      Tileset.init(),
      Char.init(),
      Poofs.init(),
      UITileset.init(),
    ]);
  });

  await setup;

  Analytics.log(EventName.APP_OPEN);
  Audio.menuMusic();

  runApp(
    OKToast(
      child: MaterialApp(
        initialRoute: ENABLE_SPLASH ? '/' : '/game',
        routes: {
          '/': (BuildContext ctx) => FlameSplashScreen(
                theme: FlameSplashTheme.dark,
                showBefore: (BuildContext context) {
                  return Image.asset(
                    'assets/images/fireslime-banner.png',
                    width: 400,
                  );
                },
                onFinish: (BuildContext context) {
                  if (ENABLE_SPLASH) {
                    Navigator.pushNamed(context, '/game');
                  }
                },
              ),
          '/options': (BuildContext ctx) =>
              const Scaffold(body: OptionsScreen()),
          '/skins': (BuildContext ctx) => const Scaffold(body: SkinsScreen()),
          '/scoreboard': (BuildContext ctx) => const Scaffold(
                body: ScoreboardScreen(),
              ),
          '/join-scoreboard': (BuildContext ctx) => const Scaffold(
                body: JoinScoreboardScreen(),
              ),
          '/credits': (BuildContext ctx) => const Scaffold(
                body: CreditsScreen(),
              ),
          '/game': (BuildContext ctx) => const Scaffold(
                body: GameScreen(),
              ),
        },
      ),
    ),
  );
}

Future<void> setMobileOrientation() async {
  if (!kIsWeb) {
    if (debugDefaultTargetPlatformOverride != TargetPlatform.fuchsia) {
      await Flame.device.setLandscape();
    }
    await Flame.device.fullScreen();
  }
}
