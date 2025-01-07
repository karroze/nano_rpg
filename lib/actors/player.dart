import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';
import 'package:flame_nano_rpg/actors/tree.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:flutter/services.dart';

enum PlayerState {
  idle,
  walk,
  attack1,
  attack2,
  attack3,
  hurt,
  die;
}

final class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks, Living, Attacking, Attackable, HasStamina, Healable {
  Player({
    required super.position,
  }) : super(
          key: ComponentKey.named('player'),
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  int get maxHealth => 100;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 15;

  @override
  int get staminaRegenPerTimeframe => 5;

  @override
  double get staminaRegenTimeframeSeconds => .5;

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

  late final hurtAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/hurt.png'),
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final dieAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/dead.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final _enemyTargets = <Enemy>[];

  final int damage = 25;

  final velocity = Vector2.zero();
  final collisionDirection = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    // Map states to animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.walk: walkAnimation,
      PlayerState.attack1: attackAnimation1,
      PlayerState.attack2: attackAnimation2,
      PlayerState.attack3: attackAnimation3,
      PlayerState.hurt: hurtAnimation,
      PlayerState.die: dieAnimation,
    };

    _setAnimationCallbacks();

    // Add hitbox
    add(
      RectangleHitbox(
        size: Vector2(54, 50),
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
    if (isAlive) {
      handleStamina(dt);
      _handleUpdateMovement(dt);
    } else {
      game.gameOver = true;
    }

    _handleAnimation(dt);
    _disposeEnemyTargets();

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Check that player is alive
    if (!isAlive) return super.onKeyEvent(event, keysPressed);

    _handleMovement(keysPressed);
    _handleCollisionDirection();
    _handleAttacking(keysPressed);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      final lookingAtEnemyOnRight = scale.x >= 1 && other.position.x >= position.x;
      final lookingAtEnemyOnLeft = scale.x < 1 && other.position.x < position.x;
      if (lookingAtEnemyOnRight || lookingAtEnemyOnLeft) {
        // Add enemy to the enemies list
        _enemyTargets.add(other);
      }
    } else if (other is Tree) {
      final targetDirection = other.position - position;
      collisionDirection.setValues(
        targetDirection.x == 0 ? 0 : targetDirection.x / targetDirection.x.abs(),
        targetDirection.y == 0 ? 0 : targetDirection.y / targetDirection.y.abs(),
      );
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Tree) {
      collisionDirection.setValues(0, 0);
    }
    super.onCollisionEnd(other);
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
      true => PlayerState.hurt,
      false => PlayerState.die,
    };
    current = damageState;
  }

  @override
  Damage dealDamage() => Damage.melee(
        amount: damage,
      );

  /// Handles what animation to play.
  void _handleAnimation(double dt) {
    // If attacked, do nothing
    if (isAttacked) return super.update(dt);

    // Update animation state
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return super.update(dt);

      // Choose random attack animation
      current = [PlayerState.attack1, PlayerState.attack2, PlayerState.attack3].random();
      return super.update(dt);
    }

    // Handle idle or walking
    if (velocity.isZero()) {
      current = PlayerState.idle;
    } else {
      current = PlayerState.walk;
    }
  }

  /// Handles movement by processing keyboard [keysPressed]-s.
  void _handleMovement(Set<LogicalKeyboardKey> keysPressed) {
    // Check for X movement
    final diffX = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft) => -1.0,
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight) => 1.0,
      _ => 0.0,
    };

    // Check for Y movement
    final diffY = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp) => -1.0,
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown) => 1.0,
      _ => 0.0,
    };

    velocity.setValues(diffX, diffY);
  }

  /// Changes [velocity] based on presence and state of [collisionDirection].
  void _handleCollisionDirection() {
    if (velocity.x != 0 && velocity.y == 0) {
      if (velocity.x == collisionDirection.x) {
        velocity.setValues(0, 0);
      } else {
        velocity.setValues(velocity.x, 0);
      }
    } else if (velocity.x == 0 && velocity.y != 0) {
      if (velocity.y == collisionDirection.y) {
        velocity.setValues(0, 0);
      } else {
        velocity.setValues(0, velocity.y);
      }
    }
  }

  /// Handles attacking
  void _handleAttacking(Set<LogicalKeyboardKey> keysPressed) {
    // Set velocity to zero if there is a pending attack
    if (isAttacking) {
      velocity.setValues(0, 0);
      return;
    }

    // Check if attack button was pressed
    isAttacking = keysPressed.contains(LogicalKeyboardKey.keyE);
    if (isAttacking) {
      // If not, set attacking to false and do nothing
      if (!hasStaminaForAttack) {
        isAttacking = false;
        isAttackingInProgress = false;
        return;
      }

      // Set movement to zero
      velocity.setValues(0, 0);

      // Decrease player stamina
      decreaseStaminaPerHit();
      // Attack every enemy target
      for (final enemyTarget in _enemyTargets) {
        attack(target: enemyTarget);
      }
    }
  }

  /// Updates player position with an update [dt] time.
  void _handleUpdateMovement(double dt) {
    // Change position
    final newPosX = position.x + velocity.x * moveSpeed * dt;
    final newPosY = position.y + velocity.y * moveSpeed * dt;

    position.setValues(
      newPosX,
      newPosY,
    );

    // Control flip
    final goesLeftLooksRight = velocity.x < 0 && scale.x > 0;
    final goesRightLooksLeft = velocity.x > 0 && scale.x < 0;
    if (goesLeftLooksRight || goesRightLooksLeft) {
      flipHorizontally();
    }
  }

  /// Clears found enemy targets at the end of every update.
  void _disposeEnemyTargets() {
    // Clear enemy targets
    _enemyTargets.clear();
  }

  /// Sets animation ticker callbacks.
  void _setAnimationCallbacks() {
    // Set attack animations tickers
    animationTickers?[PlayerState.attack1]
      ?..onStart = () {
        isAttackingInProgress = true;
      }
      ..onComplete = () {
        isAttacking = false;
        isAttackingInProgress = false;
        current = PlayerState.idle;
      };
    animationTickers?[PlayerState.attack2]
      ?..onStart = () {
        isAttackingInProgress = true;
      }
      ..onComplete = () {
        isAttacking = false;
        isAttackingInProgress = false;
        current = PlayerState.idle;
      };
    animationTickers?[PlayerState.attack3]
      ?..onStart = () {
        isAttackingInProgress = true;
      }
      ..onComplete = () {
        isAttacking = false;
        isAttackingInProgress = false;
        current = PlayerState.idle;
      };

    // Set hurt animation tickers callbacks
    animationTickers?[PlayerState.hurt]
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
        current = PlayerState.idle;
      };

    // Set die animation tickers callbacks
    animationTickers?[PlayerState.die]?.onComplete = () async {
      // Wait for some time
      await Future<void>.delayed(
        const Duration(
          milliseconds: 1250,
        ),
      );
      // Apply grayscale decorator
      decorator.addLast(
        PaintDecorator.grayscale(
          opacity: 0.5,
        ),
      );
    };
  }
}
