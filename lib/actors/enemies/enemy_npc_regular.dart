import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_npc_default_animated.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/objects/explosion.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/health_bar.dart';
import 'package:flutter/material.dart';

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

  late final HealthBar _healthBar;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    _healthBar = HealthBar(
      size: Vector2(50, 10),
      value: health,
      maxValue: maxHealth,
      position: Vector2(25, 0),
      showLabel: false,
      valueTextStyle: const TextStyle(
        fontSize: 8,
        color: Colors.black,
      ),
      anchor: Anchor.center,
    );

    add(_healthBar);
  }

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

    // Update health bar value and position
    _healthBar.value = health;

    // Handle animations
    _handleAnimation(dt);
  }

  @override
  FutureOr<void> onDie() async {
    _healthBar.removeFromParent();
    await game.add(
      Explosion(
        position: Vector2(
          position.x,
          position.y + size.y / 4,
        ),
      ),
    );
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
      attackTarget(
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
