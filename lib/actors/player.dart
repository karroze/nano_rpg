import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  idle,
  walk,
  attack1,
  attack2,
  attack3;
}

final class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks {
  Player({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  static const double moveSpeed = 50;

  late final idleAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/idle.png'),
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final walkAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/walk.png'),
    SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final attackAnimation1 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_1.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final attackAnimation2 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_2.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final attackAnimation3 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_3.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  final int damage = 25;

  Vector2 velocity = Vector2.zero();

  PositionComponent? target;

  bool isAttacking = false;
  bool attackingInProgress = false;

  @override
  FutureOr<void> onLoad() {
    // Map states to animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.walk: walkAnimation,
      PlayerState.attack1: attackAnimation1,
      PlayerState.attack2: attackAnimation2,
      PlayerState.attack3: attackAnimation3,
    };

    // Set attack animations tickers
    animationTickers?[PlayerState.attack1]?.onComplete = () {
      isAttacking = false;
      attackingInProgress = false;
    };
    animationTickers?[PlayerState.attack2]?.onComplete = () {
      isAttacking = false;
      attackingInProgress = false;
    };
    animationTickers?[PlayerState.attack3]?.onComplete = () {
      isAttacking = false;
      attackingInProgress = false;
    };

    // Add hitbox
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += velocity * moveSpeed * dt;

    // Control flip
    final goesLeftLooksRight = velocity.x < 0 && scale.x > 0;
    final goesRightLooksLeft = velocity.x > 0 && scale.x < 0;
    if (goesLeftLooksRight || goesRightLooksLeft) {
      flipHorizontally();
    }

    // Update animation state
    if (isAttacking) {
      if (!attackingInProgress) {
        current = [PlayerState.attack1, PlayerState.attack2, PlayerState.attack3].random();
        attackingInProgress = true;
      }
    } else {
      if (velocity.isZero()) {
        current = PlayerState.idle;
      } else {
        current = PlayerState.walk;
      }
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();
    // Check for jump
    // hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    // Check for attack if there is no attack in progress
    if (!isAttacking) {
      isAttacking = keysPressed.contains(LogicalKeyboardKey.keyE);
      if (isAttacking) {
        final hasEnoughStamina = game.playerStamina >= game.playerStaminaPerHit;
        if (hasEnoughStamina) {
          game.playerStamina -= game.playerStaminaPerHit;
          if(target is Enemy) {
            (target! as Enemy).receiveDamage(
              damage: damage,
              targetScale: scale,
            );
          }
        }
        else {
          isAttacking = false;
        }
      } else {
        // Check for movement
        final double diffX = switch (keysPressed) {
          final Set<LogicalKeyboardKey> keys
              when keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft) =>
            -1,
          final Set<LogicalKeyboardKey> keys
              when keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight) =>
            1,
          _ => 0,
        };
        final double diffY = switch (keysPressed) {
          final Set<LogicalKeyboardKey> keys
              when keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp) =>
            -1,
          final Set<LogicalKeyboardKey> keys
              when keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown) =>
            1,
          _ => 0,
        };
        velocity += Vector2(diffX, diffY);
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Enemy) {
      target = other;
      other.lookAtTarget(scale);
    }
    super.onCollision(intersectionPoints, other);
  }
}
