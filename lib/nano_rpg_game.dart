import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class NanoRpgGame extends FlameGame with CollisionCallbacks, HasKeyboardHandlerComponents {
  @override
  FutureOr<void> onLoad() async {
    await _loadAssets();
    await _loadPlayer();

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport.add(Hud());

    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    // Load assets
    await images.loadAll(
      [
        'player/warrior_1/idle.png',
        'player/warrior_1/walk.png',
        'player/warrior_1/attack_1.png',
        'enemies/orc_berserk/idle.png',
        'enemies/orc_berserk/walk.png',
        'enemies/orc_berserk/attack_1.png',
        'trees/tree/tree_1.png',
        'trees/tree/tree_2.png',
        'trees/tree/tree_3.png',
      ],
    );
  }

  FutureOr<void> _loadPlayer() async {
    add(
      Player(
        position: size / 2,
      ),
    );
  }
}
