import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';

final class MushroomEmerald extends MushroomComponent {
  MushroomEmerald({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 40;

  @override
  Image get image => game.images.fromCache('objects/mushrooms/mushroom_emerald.png');
}
