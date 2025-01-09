import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/objects/healing.dart';
import 'package:meta/meta.dart';

abstract class FoodComponent extends SpriteComponent with HasGameRef<NanoRpgGame>, Healer, Eatable {
  FoodComponent({
    required super.position,
    required super.size,
    super.anchor = Anchor.bottomCenter,
  });

  int get healingAmount;

  Image get image;

  @override
  Healing produceHealing() => Healing(
        amount: healingAmount,
      );

  @override
  FutureOr<void> onLoad() async{
    sprite = Sprite(image);

    // Add hitbox
    await add(
      RectangleHitbox(
        size: Vector2(54, 50),
        position: Vector2(
          size.x / 2,
          size.y,
        ),
        anchor: Anchor.bottomCenter,
      ),
    );

    return super.onLoad();
  }

  @override
  @mustCallSuper
  bool eatBy(Healable target) {
    // Try to eat food
    final wasEaten = super.eatBy(target);
    // Return false if was not eaten
    if (!wasEaten) return false;

    // Remove from parent and return true otherwise
    removeFromParent();
    return true;
  }
}
