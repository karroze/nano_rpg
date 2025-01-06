import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

final class Tree extends SpriteComponent with HasGameRef<NanoRpgGame>, CollisionCallbacks {
  Tree({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  final int maxHealth = 100;
  late int health = maxHealth;

  bool isAttacked = false;
  bool attackingInProgress = false;

  bool get isAlive => health > 0;

  @override
  FutureOr<void> onLoad() {
    // Load image from cache
    final image = game.images.fromCache('trees/tree/tree_2.png');
    // Assign it to the sprite
    sprite = Sprite(image);

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
      ),
    );

    return super.onLoad();
  }
}
