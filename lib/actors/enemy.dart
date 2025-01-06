import 'dart:async';

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

  @mustBeOverridden
  double get moveSpeed;

  @mustBeOverridden
  int get maxHealth;

  Vector2 get hitboxSize => Vector2(68, 64);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation walkAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation dieAnimation;

  late final velocity = Vector2.zero();
  late int health = maxHealth;

  bool isAttacking = false;
  bool isAttacked = false;
  bool attackingInProgress = false;

  bool get isAlive => health > 0;

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
    super.update(dt);
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

    // If target is on the right
    if (targetPosition.x >= position.x) {
      // Set scale to +1
      scale.x = 1;
    } else {
      // Set scale to -1
      scale.x = -1;
    }
  }
}