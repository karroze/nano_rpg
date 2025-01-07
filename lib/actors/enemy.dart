import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame_nano_rpg/actors/player.dart';
import 'package:meta/meta.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/explosion.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

enum EnemyState {
  idle,
  walk,
  attack,
  hurt,
  die;
}

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState> with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks {
  Enemy({
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
        );

  /// Movements
  @mustBeOverridden
  double get moveSpeed;

  @mustBeOverridden
  int get maxHealth;

  // @mustBeOverridden
  int get maxStamina => 100;

  /// Attack
  //@mustBeOverridden
  int get damage => 10;

  //@mustBeOverridden
  int get damageCooldown => 250;

  //@mustBeOverridden
  int get staminaPerHit => 25;

  //@mustBeOverridden
  double get staminaRegenTimeframeSeconds => 1;

  //@mustBeOverridden
  int get staminaRegenPerTimeframe => 10;

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

  late int health = maxHealth;
  late int stamina = maxStamina;
  late double _staminaRegenTimerValue = staminaRegenTimeframeSeconds;

  bool isAttacking = false;
  bool isAttacked = false;
  bool attackingInProgress = false;

  bool get isAlive => health > 0;

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
      attackingInProgress = false;
    };

    // Set hurt animation tickers
    animationTickers?[EnemyState.hurt]?.onComplete = () {
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
      game.add(Explosion(position: position));
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
    _handleStamina(dt);

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

  void receiveDamage({
    required int damage,
    required Vector2 targetScale,
  }) {
    // Decrease health
    health -= damage;
    // Toggle being attacked
    isAttacked = true;
    // Get new state
    final damageState = switch (isAlive) {
      true => EnemyState.hurt,
      false => EnemyState.die,
    };
    current = damageState;
  }

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

  /// Handles stamina regeneration per timeframe, decided by passed [dt].
  void _handleStamina(double dt) {
    _staminaRegenTimerValue -= dt;
    // If timer has fired and stamina is less than max
    if (_staminaRegenTimerValue <= 0 && stamina < maxStamina) {
      // Reset timer value
      _staminaRegenTimerValue = staminaRegenTimeframeSeconds;
      // Increase stamina by per timer timeframe value
      stamina += staminaRegenPerTimeframe;
      // Clamp between 0 and maxStamina value
      stamina = stamina.clamp(0, maxStamina);
    }
  }

  /// Handles interaction with a [player].
  void _handlePlayerInteraction(Player player) {
    // Get its position
    final playerPosition = player.position;
    // Find distance
    final distanceToPlayer = (playerPosition - position).length;

    if (distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    }

    if (distanceToPlayer > visibilityRange && walkPoint == null) {
      // _searchWalkPoint();
    } else if (distanceToPlayer > walkingRange && distanceToPlayer <= visibilityRange) {
      lookAtTarget(playerPosition);
    } else if (distanceToPlayer <= walkingRange && distanceToPlayer > attackRange) {
      walkToTarget(player);
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

  /// Handles what animation to play
  void _handleAnimation(double dt) {
    // If attacked, do nothing
    if (isAttacked) return super.update(dt);

    // If attacking and not already started attack animation
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (attackingInProgress) return super.update(dt);

      current = [EnemyState.attack].random();
      attackingInProgress = true;
      return super.update(dt);
    }

    // Handle idle or walking
    if (velocity.isZero()) {
      current = EnemyState.idle;
    } else {
      current = EnemyState.walk;
    }
  }
}
