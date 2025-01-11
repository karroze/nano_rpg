import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_warrior/friendly_warrior_component.dart';
import 'package:flame_nano_rpg/actors/objects/explosion.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';

abstract class SimpleEnemyComponent extends BaseNpcComponent<EnemyState> {
  SimpleEnemyComponent({
    required super.position,
    required super.size,
    required super.anchor,
  }) : super(
          priority: 3,
        );

  Player? player;

  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  @override
  int get visibilityRange => 150;

  @override
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks() => NpcAnimatorCallbacks()
    ..onAttackStarted = onAttackStarted
    ..onAttackEnded = onAttackEnded
    ..onHurtStarted = onHurtStarted
    ..onHurtEnded = onHurtEnded
    ..onDieEnded = onDieEnded;

  @override
  EnemyState? provideStateUpdate(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      return EnemyState.die;
    }

    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // Get new state
      final damageState = switch (isAlive) {
        true => EnemyState.hurt,
        false => EnemyState.die,
      };
      return damageState;
    }

    // If attacking
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return null;

      // Return random attack state
      return [EnemyState.attack].random();
    }

    // Handle idle or walking
    return switch (velocity.isZero()) {
      true => EnemyState.idle,
      false => EnemyState.walk,
    };
  }

  @override
  bool interactWith(
    BaseNpcComponent<Object> object, {
    required double distance,
  }) {
    return switch (object) {
      final Player player => handleEnemy(
          player,
          distance: distance,
        ),
      final FriendlyWarriorComponent friendlyWarrior => handleEnemy(
          friendlyWarrior,
          distance: distance,
        ),
      _ => false,
    };
  }

  @override
  List<BaseNpcComponent<Object>> filterTargets(List<BaseNpcComponent<Object>> foundTargets) {
    final player = foundTargets.whereType<Player>();
    final enemies = foundTargets.whereType<FriendlyWarriorComponent>(); // TODO(georgii.savatkov): This type lookup is bad, fix later
    return [
      ...player,
      ...enemies,
    ];
  }

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
