import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/explosion.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:meta/meta.dart';

enum EnemyState {
  idle,
  walk,
  attack,
  hurt,
  die;
}

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks, Living, Attackable, Attacking, HasStamina {
  Enemy({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  /// Movements
  @mustBeOverridden
  double get moveSpeed;

  /// Attack
  //@mustBeOverridden
  int get damage => 10;

  //@mustBeOverridden
  double get damageCooldownTimeframeSeconds => 2;
  

  /// Ranges
  double get visibilityRange => 200;

  int get walkingRange => 100;

  double get attackRange => 25;

  // Dimensions
  Vector2 get hitboxSize => Vector2(68, 64);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation walkAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation dieAnimation;

  late final velocity = Vector2.zero();

  late double _damageCooldownTimerValue = damageCooldownTimeframeSeconds;

  Player? player;
  Vector2? walkPoint;

  @override
  FutureOr<void> onLoad() {
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
    animationTickers?[EnemyState.attack]?.onComplete = () {
      isAttacking = false;
      isAttackingInProgress = false;
    };
    // Set hurt animation tickers
    animationTickers?[EnemyState.hurt]
      ?..onStart = () {
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
      ..onComplete = () {
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

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Set vero velocity
    velocity.setValues(
      0,
      0,
    );

    // Handle stamina regeneration
    handleStamina(dt);
    // Handle attacking cooldown
    _handleAttackingCooldown(dt);

    // Find player if not set
    player ??= game.findByKeyName('player');

    // If there is a player
    if (player != null) {
      _handlePlayerInteraction(player!);
    }

    // If there is a walk point
    if (walkPoint != null) {
      _handleWalkPoint(
        dt,
        walkPoint: walkPoint!,
      );
    }

    // Handle animations
    _handleAnimation(dt);

    super.update(dt);
  }

  FutureOr<void> _searchWalkPoint() async {
    final randomX = -walkingRange + Random().nextInt(walkingRange);

    walkPoint = Vector2(
      position.x + randomX,
      position.y,
    );
  }

  FutureOr<void> walkToTarget(PositionComponent target) async {
    // Do nothing if dead
    if (!isAlive) return;

    // Calculate X offset based on what side target is relative to enemy
    final xOffset = target.position.x > position.x ? -attackRange : attackRange;
    // Calculate Y offset based on what side target is relative to enemy
    // final yOffset = target.position.y > position.y ? attackRange : -attackRange;

    // Set walk point with an offset
    walkPoint = target.position + Vector2(xOffset, 0);
  }

  @override
  void receiveDamage({
    required Damage damage,
    required Attacking attacker,
  }) {
    super.receiveDamage(damage: damage, attacker: attacker);

    if (isAttackingInProgress && isAlive) return;
    // Get new state
    final damageState = switch (isAlive) {
      true => EnemyState.hurt,
      false => EnemyState.die,
    };
    current = damageState;
  }

  @override
  Damage dealDamage() => Damage.melee(
        amount: damage,
      );

  void lookAtTarget(
    Vector2 targetPosition,
  ) {
    // Do nothing if dead
    if (!isAlive) return;

    // Calculate new scale
    final newScaleX = switch (targetPosition.x - position.x >= 5) {
      true => 1.0,
      false => -1.0,
    };

    // print('Current scale: ${scale.x}\tNew scale: $newScaleX');

    // Change scale if new scale differs
    if (scale.x != newScaleX) {
      // print('Changing scale');
      scale.x = newScaleX;
    }
  }

  /// Handles attacking cooldown, decided by passing [dt].
  void _handleAttackingCooldown(double dt) {
    // Change timer value
    _damageCooldownTimerValue -= dt;
    // If timer has fired
    if (_damageCooldownTimerValue <= 0) {
      // Reset timer value
      _damageCooldownTimerValue = damageCooldownTimeframeSeconds;
      // Increase stamina by per timer timeframe value
      canAttack = true;
    } else {
      canAttack = false;
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
    } else if (distanceToPlayer > walkingRange && distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    } else if (distanceToPlayer <= walkingRange && distanceToPlayer > attackRange) {
      walkToTarget(player);
    } else if (distanceToPlayer <= attackRange && canAttack) {
      _attackPlayer(player);
    }
  }

  void _handleWalkPoint(
    double dt, {
    required Vector2 walkPoint,
  }) {
    // Go to point
    final targetDirection = walkPoint - position;

    // If there, remove walk point
    if (targetDirection.length <= attackRange) {
      // walkPoint = null;
      velocity.setValues(0, 0);
    } else {
      final isVelocityXZero = (targetDirection.x > 0 && targetDirection.x < 1) || (targetDirection.x < 0 && targetDirection.x > -1);
      final isVelocityYZero = (targetDirection.y > 0 && targetDirection.y < 1) || (targetDirection.y < 0 && targetDirection.y > -1);
      final velocityX = isVelocityXZero ? 0.0 : targetDirection.x / targetDirection.x.abs();
      final velocityY = isVelocityYZero ? 0.0 : targetDirection.y / targetDirection.y.abs();

      // print('Velocity: x: $velocityX y: $velocityY');

      velocity.setValues(
        velocityX,
        velocityY,
      );

      // Calculate new position
      final newPosX = position.x + velocity.x * moveSpeed * dt;
      final newPosY = position.y + velocity.y * moveSpeed * dt;

      // Set new position values
      position.setValues(
        newPosX,
        newPosY,
      );

      // Look at target
      lookAtTarget(walkPoint);
    }
  }

  /// Handles what animation to play.
  void _handleAnimation(double dt) {
    // If attacked, do nothing
    if (isAttacked) return super.update(dt);

    // If attacking and not already started attack animation
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return super.update(dt);

      current = [EnemyState.attack].random();
      isAttackingInProgress = true;
      return super.update(dt);
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
    if(isAlive) {
      decreaseStaminaPerHit();
      attack(target: player);
    }
  }
}
