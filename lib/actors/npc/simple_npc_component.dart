import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';
import 'package:flame_nano_rpg/actors/interactors/npc_to_npc_interaction_handler/npc_to_npc_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/npc_to_player_interaction_handler/npc_to_player_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_warrior/friendly_warrior_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';
import 'package:flame_nano_rpg/actors/objects/explosion.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

abstract class SimpleNpcComponent extends BaseNpcComponent<NpcState> {
  SimpleNpcComponent({
    required super.position,
    required super.size,
    required super.anchor,
    super.priority = 2,
  }) : super();

  @override
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks() => NpcAnimatorCallbacks()
    ..onIdleStarted = onIdleStarted
    ..onIdleEnded = onIdleStarted
    ..onAttackStarted = onAttackStarted
    ..onAttackEnded = onAttackEnded
    ..onHurtStarted = onHurtStarted
    ..onHurtEnded = onHurtEnded
    ..onDieEnded = onDieEnded;


  @override
  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  }) =>
      switch (other) {
        final Player player => NpcToPlayerInteractionHandler(
            attacker: this,
            player: player,
            payload: payload,
          ),
        final SimpleNpcComponent npc => NpcToNpcInteractionHandler(
            attacker: this,
            target: npc,
            payload: payload,
          ),
        _ => null,
      };

  @override
  NpcState? provideStateUpdate(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      return NpcState.die;
    }

    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // Get new state
      final damageState = switch (isAlive) {
        true => NpcState.hurt,
        false => NpcState.die,
      };
      return damageState;
    }

    // If attacking
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return null;

      // Return random attack state
      return [NpcState.attack].random();
    }

    // Handle idle or walking
    return switch (velocity.isZero()) {
      true => NpcState.idle,
      false => NpcState.walk,
    };
  }

  @override
  List<Interactable> filterTargets(List<Interactable> foundTargets) {
    final player = foundTargets.whereType<Player>();
    final enemies = foundTargets.whereType<Attackable>(); // TODO(georgii.savatkov): This type lookup is bad, fix later
    return [
      ...player,
      ...enemies,
    ];
  }

  @override
  FutureOr<void> onDieEnded() async {
    await animator.add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.25,
          repeatCount: 3,
        ),
      ),
    );
    await Future<void>.delayed(
      const Duration(
        milliseconds: 1250,
      ),
    );
    // Remove from parent entirely
    removeFromParent();
    // Add explosion
    await game.add(
      Explosion(
        position: position,
      ),
    );
  }
}
