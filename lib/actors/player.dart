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

  late final _enemyTargets = <Enemy>[];

  final int damage = 25;

  Vector2 velocity = Vector2.zero();

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
    // Change position
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

    // Clear enemy targets
    _enemyTargets.clear();

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();
    // Check for jump
    // hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    // Do nothing if there is a pending attack
    if (isAttacking) return super.onKeyEvent(event, keysPressed);

    // Check if attack button was pressed
    isAttacking = keysPressed.contains(LogicalKeyboardKey.keyE);
    // If so
    if (isAttacking) {
      // Check if there is enough stamina to attack
      final hasEnoughStamina = game.playerStamina >= game.playerStaminaPerHit;

      // If not, set attacking to false and do nothing
      if (!hasEnoughStamina) {
        isAttacking = false;
        return super.onKeyEvent(event, keysPressed);
      }

      // Decrease player stamina
      game.playerStamina -= game.playerStaminaPerHit;
      // Deal damage to every enemy target
      for (final enemyTarget in _enemyTargets) {
        enemyTarget.receiveDamage(
          damage: damage,
          targetScale: scale,
        );
      }
      return super.onKeyEvent(event, keysPressed);
    }

    // Check for movement
    final diffX = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys
          when keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft) =>
        -1.0,
      final Set<LogicalKeyboardKey> keys
          when keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight) =>
        1.0,
      _ => 0.0,
    };
    final diffY = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys
          when keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp) =>
        -1.0,
      final Set<LogicalKeyboardKey> keys
          when keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown) =>
        1.0,
      _ => 0.0,
    };
    velocity += Vector2(diffX, diffY);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      // Add enemy to the enemies list
      _enemyTargets.add(other);
      // Make enemy look at player
      other.lookAtTarget(position);
    }
    super.onCollision(intersectionPoints, other);
  }
}
