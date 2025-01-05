import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/game.dart';

final class NanoRpgGame extends FlameGame with CollisionCallbacks {
  @override
  FutureOr<void> onLoad() async {
    await _loadAssets();
    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    // Load assets
    await images.loadAll(
      [
        'enemies/orc_berserk/idle.png',
        'enemies/orc_berserk/walk.png',
        'enemies/orc_berserk/attack_1.png',
        'trees/tree/tree_1.png',
        'trees/tree/tree_2.png',
        'trees/tree/tree_3.png',
      ],
    );
  }
}
