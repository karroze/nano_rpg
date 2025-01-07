import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_nano_rpg/overlays/overlays.dart';
import 'package:flame_nano_rpg/worlds/main_world.dart';

final class NanoRpgGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final RouterComponent router;

  @override
  bool get debugMode => false;

  bool gameOver = false;
  bool gameReset = false;

  @override
  FutureOr<void> onLoad() async {
    router = RouterComponent(
      initialRoute: 'world',
      routes: {
        'world': WorldRoute(
          MainWorld.new,
          maintainState: false,
        ),
      },
    );

    await _loadAssets();

    add(router);

    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    // Load assets
    await images.loadAll(
      [
        'explosion.png',
        'player/warrior_1/idle.png',
        'player/warrior_1/walk.png',
        'player/warrior_1/attack_1.png',
        'player/warrior_1/attack_2.png',
        'player/warrior_1/attack_3.png',
        'player/warrior_1/hurt.png',
        'player/warrior_1/dead.png',
        'enemies/orc_berserk/idle.png',
        'enemies/orc_berserk/walk.png',
        'enemies/orc_berserk/attack_1.png',
        'enemies/orc_berserk/dead.png',
        'enemies/orc_berserk/hurt.png',
        'enemies/orc_shaman/idle.png',
        'enemies/orc_shaman/walk.png',
        'enemies/orc_shaman/attack_1.png',
        'enemies/orc_shaman/dead.png',
        'enemies/orc_shaman/hurt.png',
        'enemies/orc_warrior/idle.png',
        'enemies/orc_warrior/walk.png',
        'enemies/orc_warrior/attack_1.png',
        'enemies/orc_warrior/dead.png',
        'enemies/orc_warrior/hurt.png',
        'trees/tree/tree_1.png',
        'trees/tree/tree_2.png',
        'trees/tree/tree_3.png',
      ],
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver && !gameReset) {
      // overlays.add(Overlays.gameOver.value);
      // gameReset = true;
    }
  }

  FutureOr<void> reset() {
    // router.pushReplacementNamed('world');
    // gameOver = false;
  }
}
