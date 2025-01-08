import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/enemy_npc_default_animated.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/player.dart';

abstract class EnemyNpcRegular extends EnemyNpcDefaultAnimated {
  EnemyNpcRegular({
    required super.position,
    required super.size,
    required super.anchor,
  });

  /// Ranges
  double get visibilityRange => 200;

  int get walkingRange => 100;

  Player? player;

  @override
  void update(double dt) {
    super.update(dt);

    // Set vero velocity
    velocity.setValues(
      0,
      0,
    );

    // Handle stamina updated and movement if is alive
    if (isAlive) {
      // Handle stamina regeneration
      handleStamina(dt);
      // Handle attacking cooldown
      handleAttackingCooldown(dt);

      // Find player if not set
      player ??= game.findByKeyName('player');

      // If there is a player
      if (player != null) {
        _handlePlayerInteraction(player!);
      }

      // If there is a walk point
      if (walkPoint != null && !isAttacking) {
        handleWalkPoint(
          dt,
          walkPoint: walkPoint!,
          endDistance: attackRange,
        );
      }
    }

    // Handle animations
    _handleAnimation(dt);
  }

  FutureOr<void> _searchWalkPoint() async {
    final randomX = -walkingRange + Random().nextInt(walkingRange);

    // walkToTarget(
    //   game.size / 2,
    // );

    print('Point: ${game.size / 2}');
    print('Target: ${position + Vector2(400, 0)}');

    setWalkTarget(
      position +
          Vector2(
            randomX.toDouble(),
            0,
          ),
    );
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
    } else if (distanceToPlayer > walkingRange && distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    } else if (distanceToPlayer <= walkingRange && distanceToPlayer > attackRange) {
      setWalkTarget(player.position);
    } else if (distanceToPlayer <= attackRange && canAttack) {
      attack(
        target: player,
      );
    }
  }

  /// Handles what animation to play.
  void _handleAnimation(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      current = EnemyState.die;
      return;
    }

    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // Get new state
      final damageState = switch (isAlive) {
        true => EnemyState.hurt,
        false => EnemyState.die,
      };
      current = damageState;
      return;
    }

    // If attacking
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return;

      current = [EnemyState.attack].random();
      return;
    }

    // Handle idle or walking
    if (velocity.isZero()) {
      current = EnemyState.idle;
    } else {
      current = EnemyState.walk;
    }
  }
}
