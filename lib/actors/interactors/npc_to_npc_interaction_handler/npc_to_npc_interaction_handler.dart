import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_stamina.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/npc/simple_npc_component.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

final class NpcToNpcInteractionHandler extends InteractionHandler {
  NpcToNpcInteractionHandler({
    required this.attacker,
    required this.target,
    required super.payload,
    this.callbacks,
  });

  final SimpleNpcComponent attacker;
  final SimpleNpcComponent target;
  EatInteractionHandlerCallbacks? callbacks;

  @override
  bool performInteraction() {
    // Get target position
    final targetPosition = target.position;

    // Look at enemy if within visibility range but not within move range
    final playerWithinVisibilityRange = payload.distance > attacker.moveDistance && payload.distance <= attacker.visibilityDistance;
    if (playerWithinVisibilityRange) {
      attacker.lookAtTarget(targetPosition);
      return false;
    }

    // Don't attack same fraction
    if(attacker.fraction == target.fraction) return false;

    // Set walk target to the enemy if within move range but not within attack range
    final playerWithinWalkRange = payload.distance <= attacker.moveDistance && payload.distance > attacker.attackDistance;
    if (playerWithinWalkRange) {
      attacker.setWalkTarget(
        targetPosition,
        endDistance: attacker.attackDistance,
      );
      return true;
    }
    // Attack enemy if within attack range and can attack
    final playerWithinAttackRange = payload.distance <= attacker.attackDistance && attacker.canAttack && attacker.hasStaminaForAttack;
    if (playerWithinAttackRange) {
      attacker.attackTarget(
        target: target,
      );
      return true;
    }

    return false;
  }
}
