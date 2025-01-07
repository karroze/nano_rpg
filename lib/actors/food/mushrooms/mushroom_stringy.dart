import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';

final class MushroomStringy extends MushroomComponent {
  MushroomStringy({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 30;

  @override
  Image get image => game.images.fromCache('objects/mushrooms/mushroom_stringy.png');
}
