import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/enemy_npc.dart';
import 'package:flame_nano_rpg/actors/npc/friendly_npc_default_animated.dart';
import 'package:flame_nano_rpg/actors/npc/npc_state.dart';
import 'package:flame_nano_rpg/actors/player.dart';

abstract class FriendlyNpcRegular extends FriendlyNpcDefaultAnimated {
  FriendlyNpcRegular({
    required super.position,
    required super.size,
    required super.anchor,
  });

  /// Ranges
  double get visibilityRange => 200;

  int get walkingRange => 100;

  Player? player;

  late final _enemyTargets = <EnemyNpc<Object>>[];

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

        // Check if player has enemies
        if(player!.enemyTargets.isNotEmpty) {
          // Get last
          final playerEnemy = player!.enemyTargets.last;
          // Attack every enemy target
          _handleEnemyInteraction(playerEnemy);
        }
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
    }
    // else if (distanceToPlayer <= attackRange && canAttack) {
    //   attack(
    //     target: player,
    //   );
    // }
  }

  /// Handles interaction with an [enemy].
  void _handleEnemyInteraction(EnemyNpc<Object> enemy) {
    // Get its position
    final enemyPosition = enemy.position;
    // Find distance
    final distanceToEnemy = (enemyPosition - position).length - (enemy.size / 4).length;

    // if (distanceToEnemy <= visibilityRange) {
    //   lookAtTarget(enemyPosition);
    // }

    if (distanceToEnemy > attackRange) {
      setWalkTarget(enemy.position);
    } else if (distanceToEnemy <= attackRange && canAttack) {
      attack(
        target: enemy,
      );
    }
  }

  /// Handles what animation to play.
  void _handleAnimation(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      current = NpcState.die;
      return;
    }

    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // Get new state
      final damageState = switch (isAlive) {
        true => NpcState.hurt,
        false => NpcState.die,
      };
      current = damageState;
      return;
    }

    // If attacking
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return;

      current = [NpcState.attack].random();
      return;
    }

    // Handle idle or walking
    if (velocity.isZero()) {
      current = NpcState.idle;
    } else {
      current = NpcState.walk;
    }
  }
}
