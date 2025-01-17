import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_nano_rpg/gen/assets.gen.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

final class Tree extends SpriteComponent with HasGameRef<NanoRpgGame>, CollisionCallbacks {
  Tree({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  FutureOr<void> onLoad() async {
    // Load image from cache
    final image = game.images.fromCache(Assets.images.trees.tree.tree2.keyName);
    // Assign it to the sprite
    sprite = Sprite(image);

    await add(
      RectangleHitbox(
        size: Vector2(48, 64),
        position: Vector2(
          size.x / 2,
          size.y,
        ),
        anchor: Anchor.bottomCenter,
        collisionType: CollisionType.passive,
      ),
    );

    return super.onLoad();
  }
}
