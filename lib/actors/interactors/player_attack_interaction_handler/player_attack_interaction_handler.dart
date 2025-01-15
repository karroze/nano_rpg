import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

final class PlayerAttackInteractionHandler extends InteractionHandler {
  PlayerAttackInteractionHandler({
    required this.attacker,
    required this.target,
    required super.payload,
    this.callbacks,
  });

  final Player attacker;
  final Attackable target;
  EatInteractionHandlerCallbacks? callbacks;

  @override
  bool performInteraction() {
    // Check that attack can be performed
    final canAttack = payload.distance <= attacker.attackDistance && attacker.hasStaminaForAttack && attacker.canAttack;
    // Attack target if possible
    if (canAttack && attacker.isAttacking) {
      attacker.attackTarget(
        target: target,
      );
    }

    // Return interaction result
    return canAttack;
  }
}
