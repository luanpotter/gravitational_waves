import 'package:dartlin/collections.dart';
import 'package:flame/components.dart';
import 'package:gravitational_waves/game/collections.dart';
import 'package:gravitational_waves/game/components/background.dart';
import 'package:gravitational_waves/game/components/revamped/crystal_container_pickup.dart';
import 'package:gravitational_waves/game/components/revamped/firing_ship.dart';
import 'package:gravitational_waves/game/components/revamped/jetpack_pickup.dart';
import 'package:gravitational_waves/game/components/revamped/space_battle.dart';
import 'package:gravitational_waves/game/game.dart';
import 'package:gravitational_waves/game/spawner.dart';
import 'package:gravitational_waves/game/util.dart';

// change this if you want to easily test all powerups.
const _M = 1.0;

class Powerups extends Component with HasGameRef<MyGame> {
  static Spawner spaceBattleSpawner = Spawner(0.015 * _M);
  static Spawner jetpackSpawner = Spawner(0.5 * _M);
  static Spawner crystalContainerSpawner = Spawner(0.15 * _M);

  bool hasSpaceBattle = false;

  Powerups();

  void reset() {
    hasSpaceBattle = false;
  }

  @override
  void update(double dt) {
    if (gameRef.sleeping || !gameRef.enablePowerups) {
      return;
    }
    super.update(dt);
    _maybeGeneratePowerups(dt);
  }

  void _maybeGeneratePowerups(double dt) {
    if (!hasSpaceBattle) {
      spaceBattleSpawner.maybeSpawn(dt, () {
        hasSpaceBattle = true;
        gameRef.camera.viewport.add(SpaceBattle());
      });
    }

    jetpackSpawner.maybeSpawn(dt, () {
      final p = maybeGetOffscreenPosition();
      if (p != null) {
        final type = JetpackType.values.sample(R);
        gameRef.add(JetpackPickup(type, p.x, p.y));
      }
    });

    crystalContainerSpawner.maybeSpawn(dt, () {
      final p = maybeGetOffscreenPosition();
      if (p != null) {
        gameRef.add(CrystalContainerPickup(p.x, p.y));
      }
    });
  }

  Vector2? maybeGetOffscreenPosition() {
    final offscreenX = gameRef.cameraX + gameRef.size.x + 1;
    final firstOffscreen = gameRef.children
        .whereType<Background>()
        .firstOrNull((c) => c.x > offscreenX);
    if (firstOffscreen == null) {
      return null;
    }
    final idx = firstOffscreen.columns.randomIdx(R);
    final x = firstOffscreen.x + (idx + 0.5) * BLOCK_SIZE;
    final y = firstOffscreen.columns[idx].randomYHeight() + BLOCK_SIZE / 2;
    return Vector2(x, y);
  }

  void spawnFiringShip() {
    if (!gameRef.sleeping) {
      gameRef.camera.viewport.add(FiringShip());
    }
  }
}
