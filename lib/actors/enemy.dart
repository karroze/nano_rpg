import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';
import 'package:flame_nano_rpg/actors/explosion.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

enum EnemyState {
  idle,
  walk,
  attack,
  hurt,
  die;
}

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks, Living, Moving, Attackable, Attacking, AttackingWithCooldown, HasStamina {
  Enemy({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  /// Ranges
  double get visibilityRange => 200;

  int get walkingRange => 100;

  // Dimensions
  Vector2 get hitboxSize => Vector2(68, 64);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation walkAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation dieAnimation;

  Player? player;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    await _loadAnimations();

    // Add hitbox
    add(
      RectangleHitbox(
        size: hitboxSize,
        position: Vector2(
          size.x / 2,
          size.y,
        ),
        anchor: Anchor.bottomCenter,
      ),
    );
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
      _attackPlayer(player);
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

  /// Attacks [player] and decreases stamina.
  void _attackPlayer(Player player) {
    if (isAlive) {
      decreaseStaminaPerHit();
      attack(target: player);
      canAttack = false;
    }
  }

  FutureOr<void> _loadAnimations() {
    // Map states to animations
    animations = {
      EnemyState.idle: idleAnimation,
      EnemyState.walk: walkAnimation,
      EnemyState.attack: attackAnimation,
      EnemyState.hurt: hurtAnimation,
      EnemyState.die: dieAnimation,
      // PlayerState.attack2: attackAnimation2,
      // PlayerState.attack3: attackAnimation3,
    };

    // Set attack animation tickers
    animationTickers?[EnemyState.attack]
      ?..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };
    // Set hurt animation tickers
    animationTickers?[EnemyState.hurt]
      ?..onStart = () async {
        add(
          OpacityEffect.fadeOut(
            EffectController(
              alternate: true,
              duration: 0.125,
              repeatCount: 2,
            ),
          ),
        );
      }
      ..onComplete = () async {
        isAttacked = false;
        current = EnemyState.idle;
      };

    // Set die animation tickers
    animationTickers?[EnemyState.die]?.onComplete = () async {
      add(
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
      game.add(
        Explosion(
          position: position,
        ),
      );
      removeFromParent();
    };
    // animationTickers?[PlayerState.attack2]?.onComplete = () {
    //   isAttacking = false;
    //   attackingInProgress = false;
    // };
    // animationTickers?[PlayerState.attack3]?.onComplete = () {
    //   isAttacking = false;
    //   attackingInProgress = false;
    // };
  }
}
