import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

final class PlayerAttackInteractionHandler extends InteractionHandler {
  PlayerAttackInteractionHandler({
    required this.player,
    required this.target,
    required super.payload,
    this.callbacks,
  });

  final Player player;
  final Attackable target;
  EatInteractionHandlerCallbacks? callbacks;

  @override
  bool performInteraction() {
    // Don't attack same fraction
    if (player.fraction == target.fraction) return false;
    // Check that attack can be performed
    final canAttack = payload.distance <= player.attackDistance && player.hasStaminaForAttack && player.canAttack;
    // Attack target if possible
    if (canAttack && player.isAttacking && !player.isAttackingInProgress) {
      // Set player velocity to zero
      player.velocity.setValues(
        0,
        0,
      );
      // Attack target
      player.attackTarget(
        target: target,
      );
    }

    // Return interaction result
    return canAttack;
  }
}
