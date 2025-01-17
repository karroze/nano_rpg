import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/npc/simple_npc_component.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

final class NpcToPlayerInteractionHandler extends InteractionHandler {
  NpcToPlayerInteractionHandler({
    required this.attacker,
    required this.player,
    required super.payload,
    this.callbacks,
  });

  final SimpleNpcComponent attacker;
  final Player player;
  EatInteractionHandlerCallbacks? callbacks;

  @override
  bool performInteraction() {
    // Get target position
    final targetPosition = player.position;

    // Don't attack same fraction
    final sameFraction = attacker.fraction == player.fraction;

    // Look at enemy if within visibility range but not within move range
    final playerWithinVisibilityRange = payload.distance > attacker.moveDistance && payload.distance <= attacker.visibilityDistance;
    if (playerWithinVisibilityRange) {
      attacker.lookAtTarget(targetPosition);
      return false;
    }

    // Set walk target to the enemy if within move range but not within attack range
    final playerWithinWalkRange = payload.distance <= attacker.moveDistance && payload.distance > attacker.attackDistance;
    if (playerWithinWalkRange && sameFraction) {
      attacker.setWalkTarget(
        targetPosition,
        endDistance: attacker.attackDistance,
      );
      return true;
    }

    return false;
  }
}
