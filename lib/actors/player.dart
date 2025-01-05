import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  idle,
  walk,
  attack;
}

final class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<NanoRpgGame>, KeyboardHandler {
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

  late final attackAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_1.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  int health = 100;
  int stamina = 100;
  Vector2 velocity = Vector2.zero();

  bool isAttacking = false;

  @override
  FutureOr<void> onLoad() {
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.walk: walkAnimation,
      PlayerState.attack: attackAnimation,
    };

    animationTickers?[PlayerState.attack]?.onComplete = () {
      isAttacking = false;
    };

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

    if (isAttacking) {
      current = PlayerState.attack;
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
    // Check for jump
    // hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    // Check for attack if there is no attack in progress
    if (!isAttacking) {
      isAttacking = keysPressed.contains(LogicalKeyboardKey.keyE);
      // Check for movement
      velocity = Vector2.zero();
      if (!isAttacking) {
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
}
