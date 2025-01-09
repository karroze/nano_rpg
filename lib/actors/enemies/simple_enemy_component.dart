import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
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

  double get visibilityRange => 150;

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
  void handleInteractions() {
    // TODO(georgii.savatkov): This is bad but ok for now
    // Find player if not set
    player ??= game.findByKeyName('player');

    // If there is a player
    if (player != null) {
      _handlePlayerInteraction(player!);
    }
  }

  /// Handles interaction with a [player].
  void _handlePlayerInteraction(Player player) {
    // Get its position
    final playerPosition = player.position;
    // Find distance
    final distanceToPlayer = (playerPosition - position).length - (player.size / 4).length;

    if (distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    }

    if (distanceToPlayer > visibilityRange && walkPoint == null) {
      // _searchWalkPoint();
    } else if (distanceToPlayer > moveDistance && distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    } else if (distanceToPlayer <= moveDistance && distanceToPlayer > attackRange) {
      setWalkTarget(player.position);
    } else if (distanceToPlayer <= attackRange && canAttack) {
      attackTarget(
        target: player,
      );
    }
  }

  FutureOr<void> onAttackStarted() {
    isAttackingInProgress = true;
  }

  FutureOr<void> onAttackEnded() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  FutureOr<void> onDieStarted() => null;

  FutureOr<void> onDieEnded() async {
    animator.add(
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
    // await onDie();
    removeFromParent();
  }

  FutureOr<void> onHurtStarted() {
    animator.add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.125,
          repeatCount: 2,
        ),
      ),
    );
  }

  FutureOr<void> onHurtEnded() {
    isAttacked = false;
    isAttacking = false;
    isAttackedInProgress = false;
  }
}
