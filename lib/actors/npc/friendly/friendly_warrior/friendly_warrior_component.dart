import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_warrior/friendly_warrior_animator.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class FriendlyWarriorComponent extends BaseNpcComponent<NpcState> {
  FriendlyWarriorComponent({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  Player? player;

  @override
  int get maxHealth => 250;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 20;

  @override
  int get staminaRegenPerTimeframe => 5;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  double get moveSpeed => 50;

  @override
  double get moveDistance => 100;

  double get visibilityRange => 150;

  @override
  double get attackRange => 25;

  @override
  double get damageCooldownTimeframeSeconds => 2;

  // Dimensions
  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  @override
  List<Attack> get availableAttacks => [
        const Attack(
          title: 'Simple',
          damage: 20,
          damageCrit: 25,
          critChance: .15,
          range: 25,
        ),
      ];

  @override
  FutureOr<SimpleCharacterAnimator<NpcState>> provideAnimationGroupComponent() => FriendlyWarriorAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );

  @override
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks() => NpcAnimatorCallbacks()
    ..onAttackStarted = onAttackStarted
    ..onAttackEnded = onAttackEnded
    ..onHurtStarted = onHurtStarted
    ..onHurtEnded = onHurtEnded
    ..onDieEnded = onDieEnded;

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
  void interactWith() {
    // TODO: implement interactWith
  }

  @override
  void handleInteractions() {
    // TODO(georgii.savatkov): This is bad but ok for now
    // Find player if not set
    player ??= game.findByKeyName('player');

    // If there is a player
    if (player != null) {
      _handlePlayerInteraction(player!);

      // Check if player has enemies
      if (player!.enemyTargets.isNotEmpty) {
        // Get last
        final playerEnemy = player!.enemyTargets.last;
        // Attack every enemy target
        _handleEnemyInteraction(playerEnemy);
      }
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
    }
    // else if (distanceToPlayer <= attackRange && canAttack) {
    //   attack(
    //     target: player,
    //   );
    // }
  }

  /// Handles interaction with an [enemy].
  void _handleEnemyInteraction(BaseNpcComponent<Object> enemy) {
    // Get its position
    final enemyPosition = enemy.position;
    // Find distance
    final distanceToEnemy = (enemyPosition - position).length - (enemy.size / 4).length;

    if (distanceToEnemy <= visibilityRange) {
      lookAtTarget(enemyPosition);
    }

    if (distanceToEnemy > attackRange) {
      setWalkTarget(enemy.position);
    } else if (distanceToEnemy <= attackRange && canAttack) {
      attackTarget(
        target: enemy,
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
    // await onDie();
    removeFromParent();
  }

  FutureOr<void> onHurtStarted() async {
   await animator.add(
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
