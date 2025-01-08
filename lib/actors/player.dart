import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame/src/sprite_animation_ticker.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/base_npc.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/enemy_npc.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';
import 'package:flame_nano_rpg/actors/objects/tree.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
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

final class Player extends Character<PlayerState> with KeyboardHandler, CollisionCallbacks, Living, Attacking, Attackable, HasStamina, Healable, Moving {
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

  @override
  double get moveSpeed => 50;

  @override
  double get moveDistance => 100;

  @override
  double get attackRange => 25;

  @override
  int get damageAmount => 25;

  @override
  int get critDamageAmount => 50;

  @override
  double get critChance => .2;

  late final _enemyTargets = <EnemyNpc<Object>>[];

  final collisionDirection = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
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
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle stamina updated and movement if is alive
    if (isAlive) {
      handleStamina(dt);
      _handleUpdateMovement(dt);
    } else {
      game.gameOver = true;
    }

    _handleAnimation(dt);
    _disposeEnemyTargets();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Check that player is alive
    if (!isAlive) return super.onKeyEvent(event, keysPressed);

    final key = event.logicalKey;

    final handledMovement = _handleMovement(keysPressed);
    final handledCollision = _handleCollisionDirection();
    final handledAttacking = _handleAttacking(key);

    final handled = handledMovement || handledCollision || handledAttacking;

    // Propagate handler further if no action was performed
    if (!handled) return false;

    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Eatable) {
      final wasEaten = (other as Eatable).eatBy(this);
      if (wasEaten) {
        add(
          ScaleEffect.by(
            Vector2.all(1.2),
            EffectController(
              alternate: true,
              duration: 0.125,
              repeatCount: 2,
            ),
          ),
        );
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyNpc<Object>) {
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
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Tree) {
      collisionDirection.setValues(0, 0);
    }
  }

  /// Handles what animation to play.
  void _handleAnimation(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      // print('Animation handling: isAlive: false, setting PlayerState.die');
      current = PlayerState.die;
      return;
    }
    // print('Animation handling: isAlive: true');
    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // print('Animation handling: isAttacked: true, isAttackedInProgress: $isAttackedInProgress');
      // If there is an attacking in progress, do nothing
      if (isAttackedInProgress || isAttackingInProgress) return;
      // Get new state
      final damageState = switch (isAlive) {
        true => PlayerState.hurt,
        false => PlayerState.die,
      };
      // print('Animation handling: isAttacked: true, isAlive: $isAlive, setting state: $damageState');
      current = damageState;
      return;
    }
    // print('Animation handling: isAttacked: false');

    // If attacking
    if (isAttacking) {
      // print('Animation handling: isAttacking: true, isAttackingInProgress: $isAttackingInProgress');
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return;

      // Choose random attack animation
      current = [PlayerState.attack1, PlayerState.attack2, PlayerState.attack3].random();
      // print('Animation handling: isAttacking: true, isAttackingInProgress: false, setting state: $current');
      return;
    }

    // print('Animation handling: isAttacking: false');

    // Handle idle or walking
    if (velocity.isZero()) {
      current = PlayerState.idle;
    } else {
      current = PlayerState.walk;
    }

    // print('Animation handling: setting state: $current');
  }

  /// Handles movement by processing keyboard [keysPressed]-s.
  ///
  /// Returns true if movement was handled.
  bool _handleMovement(Set<LogicalKeyboardKey> keysPressed) {
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
    return true;
  }

  /// Changes [velocity] based on presence and state of [collisionDirection].
  bool _handleCollisionDirection() {
    if (velocity.x != 0 && velocity.y == 0) {
      if (velocity.x == collisionDirection.x) {
        velocity.setValues(0, 0);
      } else {
        velocity.setValues(velocity.x, 0);
      }
      return true;
    } else if (velocity.x == 0 && velocity.y != 0) {
      if (velocity.y == collisionDirection.y) {
        velocity.setValues(0, 0);
      } else {
        velocity.setValues(0, velocity.y);
      }
      return true;
    }

    return false;
  }

  /// Handles attacking
  bool _handleAttacking(LogicalKeyboardKey key) {
    // Set velocity to zero if there is a pending attack
    if (isAttacking) {
      velocity.setValues(0, 0);
      return false;
    }

    // Check if attack button was pressed
    isAttacking = key == LogicalKeyboardKey.keyE;
    if (isAttacking) {
      // If not, set attacking to false and do nothing
      if (!hasStaminaForAttack) {
        isAttacking = false;
        isAttackingInProgress = false;
        return false;
      }

      // Set movement to zero
      velocity.setValues(0, 0);

      // Decrease player stamina
      decreaseStaminaPerHit();
      // Attack every enemy target
      for (final enemyTarget in _enemyTargets) {
        attack(target: enemyTarget);
      }

      return true;
    }
    return false;
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
      ?..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };
    animationTickers?[PlayerState.attack2]
      ?..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };
    animationTickers?[PlayerState.attack3]
      ?..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };

    // Set hurt animation tickers callbacks
    animationTickers?[PlayerState.hurt]
      ?..onStart = () async {
        // print('Animation: hurt: starting, iAttacked: $isAttacked');
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
        isAttacking = false;
        isAttackedInProgress = false;
        // print('Animation: hurt: ending, iAttacked: $isAttacked, isAttackedInProgress: $isAttackedInProgress');
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

  @override
  FutureOr<void> setupAnimationTickers({
    required EnemyState state,
    required SpriteAnimationTicker ticker,
  }) {
    final _ = switch (state) {
      EnemyState.attack => _setupAttackAnimationTicker(ticker),
      EnemyState.hurt => _setupHurtAnimationTicker(ticker),
      EnemyState.die => _setupDieAnimationTicker(ticker),
      _ => null,
    };
  }

  /// Sets attack animation ticker callbacks.
  FutureOr<void> _setupAttackAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker
      ..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };
  }

  /// Sets hurt animation ticker callbacks.
  FutureOr<void> _setupHurtAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker
      ..onStart = () async {
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
        isAttacking = false;
        isAttackedInProgress = false;
      };
  }

  /// Sets die animation ticker callbacks.
  FutureOr<void> _setupDieAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker.onComplete = () async {
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
      await onDie();
      removeFromParent();
    };
  }

  @override
  FutureOr<Map<PlayerState, SpriteAnimation>> setupAnimations() {
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

    return {
      PlayerState.idle: idleAnimation,
      PlayerState.walk: walkAnimation,
      PlayerState.attack1: attackAnimation1,
      PlayerState.attack2: attackAnimation2,
      PlayerState.attack3: attackAnimation3,
      PlayerState.hurt: hurtAnimation,
      PlayerState.die: dieAnimation,
    };
  }
}
