import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';

final class MushroomBlueHat extends MushroomComponent {
  MushroomBlueHat({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 20;

  @override
  Image get image => game.images.fromCache('objects/mushrooms/mushroom_blue_hat.png');
}
