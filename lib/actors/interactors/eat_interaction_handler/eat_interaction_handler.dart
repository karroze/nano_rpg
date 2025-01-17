import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';

final class EatInteractionHandler extends InteractionHandler {
  EatInteractionHandler({
    required this.eatable,
    required this.target,
    required super.payload,
    this.callbacks,
  });

  final Eatable eatable;
  final Healable target;
  EatInteractionHandlerCallbacks? callbacks;

  @override
  bool performInteraction() {
    // Check that within interaction distance
    if (payload.distance > eatable.interactionDistance) return false;
    // Proceed only when target is interacting
    if (!target.isInteracting) return false;
    // Return if sender was eaten by target
    final wasEaten = eatable.eatBy(target);
    // If eatable was eaten, call corresponding callback
    if (wasEaten) {
      callbacks?.onEatableConsumed?.call(eatable);
    }
    // Return interaction result
    return wasEaten;
  }
}
