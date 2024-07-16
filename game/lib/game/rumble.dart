import 'package:flutter/services.dart' show HapticFeedback;
import 'package:gravitational_waves/game/preferences.dart';

class Rumble {
  static void rumble() {
    if (!Preferences.instance.rumbleOn) {
      return;
    }
    HapticFeedback.vibrate();
  }
}
