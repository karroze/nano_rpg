import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/food/food_component.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

abstract class MushroomComponent extends FoodComponent {
  MushroomComponent({
    required super.position,
    required super.size,
  });

  @override
  double get interactionDistance => 25;

  @override
  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  }) =>
      null;
}
