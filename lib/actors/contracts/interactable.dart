import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';

mixin Interactable on PositionComponent {
  /// Distance within which object is interactable.
  double get interactionDistance;

  // /// Returns boolean if can interact with another [Interactable].
  // bool canInteractWith(Interactable other);

  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  });
}

final class InteractionPayload {
  const InteractionPayload({
    required this.distance,
  });

  final double distance;
}

abstract class InteractionHandler {
  const InteractionHandler({
    required this.payload,
  });

  final InteractionPayload payload;

  bool performInteraction();
}

final class HealInteractionHandler extends InteractionHandler {
  const HealInteractionHandler({
    required this.eatable,
    required this.target,
    required super.payload,
  });

  final Healer eatable;
  final Healable target;

  @override
  bool performInteraction() {
    target.receiveHealing(
      healing: eatable.produceHealing(),
      healer: eatable,
    );
    return true;
  }
}

final class EatInteractionHandler extends InteractionHandler {
  const EatInteractionHandler({
    required this.sender,
    required this.target,
    required super.payload,
  });

  final Eatable sender;
  final Healable target;

  @override
  bool performInteraction() {
    print('AAAA');
    // Check that within interaction distance
    if (payload.distance > sender.interactionDistance) return false;
    // Return if sender was eaten by target
    return sender.eatBy(target);
  }
}
