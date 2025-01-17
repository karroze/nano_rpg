import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom.dart';
import 'package:flame_nano_rpg/gen/assets.gen.dart';

final class MushroomEmerald extends MushroomComponent {
  MushroomEmerald({
    required super.position,
  }) : super(
          size: Vector2.all(64),
        );

  @override
  int get healingAmount => 40;

  @override
  Image get image => game.images.fromCache(Assets.images.objects.mushrooms.mushroomEmerald.keyName);
}
