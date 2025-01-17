import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';
import 'package:flame_nano_rpg/gen/assets.gen.dart';

final class MushroomPurple extends MushroomComponent {
  MushroomPurple({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 25;

  @override
  Image get image => game.images.fromCache(Assets.images.objects.mushrooms.mushroomPurple.keyName);
}
