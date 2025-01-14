import 'package:flame_nano_rpg/actors/food/food_component.dart';

abstract class MushroomComponent extends FoodComponent {
  MushroomComponent({
    required super.position,
    required super.size,
  });

  @override
  double get interactionDistance => 25;
}
