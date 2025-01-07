import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';

final class MushroomPurple extends MushroomComponent {
  MushroomPurple({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 25;

  @override
  Image get image => game.images.fromCache('objects/mushrooms/mushroom_purple.png');
}
