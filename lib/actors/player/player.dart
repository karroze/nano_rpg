import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/actors/objects/tree.dart';
import 'package:flame_nano_rpg/actors/player/player_animator.dart';
import 'package:flame_nano_rpg/actors/player/player_state.dart';
import 'package:flame_nano_rpg/objects/attack.dart';
import 'package:flutter/services.dart';

final class Player extends BaseNpcComponent<PlayerState> with KeyboardHandler, CollisionCallbacks, Healable {
  Player({
    required super.position,
  }) : super(
          key: ComponentKey.named('player'),
          priority: 2,
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  int get maxHealth => 100;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 10;

  @override
  int get staminaRegenPerTimeframe => 10;

  @override
  double get staminaRegenTimeframeSeconds => .5;

  @override
  double get moveSpeed => 50;

  @override
  double get moveDistance => 100;

  @override
  double get attackRange => 25;

  @override
  List<Attack> get availableAttacks => [
        const Attack(
          title: 'Simple',
          damage: 25,
          damageCrit: 40,
          critChance: .2,
          range: 25,
        ),
      ];

  @override
  double get damageCooldownTimeframeSeconds => 0;

  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  late final enemyTargets = <SimpleEnemyComponent>[];

  final collisionDirection = Vector2.zero();

  @override
  void update(double dt) {
    // Handle movement if is alive
    if (isAlive) {
      _handleUpdateMovement(dt);
    }

    super.update(dt);
    // _disposeEnemyTargets();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Check that player is alive
    if (!isAlive) return super.onKeyEvent(event, keysPressed);

    final key = event.logicalKey;

    final handledMovement = _handleMovement(keysPressed);
    // final handledCollision = _handleCollisionDirection();
    final handledAttacking = _handleAttacking(key);

    final handled = handledMovement || handledAttacking;

    // Propagate handler further if no action was performed
    if (!handled) return false;

    return true;
  }

  @override
  FutureOr<SimpleCharacterAnimator<PlayerState>> provideAnimationGroupComponent() => PlayerAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );

  @override
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks() => NpcAnimatorCallbacks()
    ..onAttackStarted = onAttackStarted
    ..onAttackEnded = onAttackEnded
    ..onHurtStarted = onHurtStarted
    ..onHurtEnded = onHurtEnded
    ..onDieEnded = onDieEnded;

  @override
  FutureOr<void> setupUi() {
    super.setupUi();
    healthBar.removeFromParent();
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

    if (other is SimpleEnemyComponent) {
      final lookingAtEnemyOnRight = animator.scale.x >= 1 && other.position.x >= position.x;
      final lookingAtEnemyOnLeft = animator.scale.x < 1 && other.position.x < position.x;
      if (lookingAtEnemyOnRight || lookingAtEnemyOnLeft) {
        // Add enemy to the enemies list
        if (enemyTargets.contains(other)) {
          enemyTargets.remove(other);
        }
        enemyTargets.add(other);
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
    } else if (other is SimpleEnemyComponent) {
      enemyTargets.remove(other);
    }
  }

  /// Handles what animation to play.
  @override
  PlayerState? provideStateUpdate(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      // print('Animation handling: isAlive: false, setting PlayerState.die');
      return PlayerState.die;
    }
    // print('Animation handling: isAlive: true');
    // If attacked choose between hurt and dead animation based on if alive
    if (isAttacked) {
      // print('Animation handling: isAttacked: true, isAttackedInProgress: $isAttackedInProgress');
      // If there is an attacking in progress, do nothing
      if (isAttackedInProgress || isAttackingInProgress) return null;
      // Get new state
      return switch (isAlive) {
        true => PlayerState.hurt,
        false => PlayerState.die,
      };
      // print('Animation handling: isAttacked: true, isAlive: $isAlive, setting state: $damageState');
    }
    // print('Animation handling: isAttacked: false');

    // If attacking
    if (isAttacking) {
      // print('Animation handling: isAttacking: true, isAttackingInProgress: $isAttackingInProgress');
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return null;

      // print('Animation handling: isAttacking: true, isAttackingInProgress: false, setting state: $current');
      // Choose random attack animation
      return [PlayerState.attack1, PlayerState.attack2, PlayerState.attack3].random();
    }

    // print('Animation handling: isAttacking: false');

    // Handle idle or walking
    return switch (velocity.isZero()) {
      true => PlayerState.idle,
      false => PlayerState.walk,
    };

    // print('Animation handling: setting state: $current');
  }

  @override
  void handleInteractions() {}

  FutureOr<void> onAttackStarted() {
    isAttackingInProgress = true;
  }

  FutureOr<void> onAttackEnded() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  FutureOr<void> onHurtStarted() {
    animator.add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.125,
          repeatCount: 2,
        ),
      ),
    );
  }

  FutureOr<void> onHurtEnded() {
    isAttacked = false;
    isAttacking = false;
    isAttackedInProgress = false;
  }

  FutureOr<void> onDieStarted() => null;

  FutureOr<void> onDieEnded() async {
    // Wait for some time
    await Future<void>.delayed(
      const Duration(
        milliseconds: 1250,
      ),
    );
    // Apply grayscale decorator
    animator.decorator.addLast(
      PaintDecorator.grayscale(
        opacity: 0.5,
      ),
    );
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

    velocity.setValues(
      diffX,
      diffY,
    );
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

  /// Clears found enemy targets at the end of every update.
  void _disposeEnemyTargets() {
    // Clear enemy targets
    enemyTargets.clear();
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

      // Manually decrease stamina even if no enemy targets were hit
      decreaseStaminaPerHit();

      // Attack every enemy target
      for (final enemyTarget in enemyTargets) {
        attackTarget(target: enemyTarget);
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
    final goesLeftLooksRight = velocity.x < 0 && animator.scale.x > 0;
    final goesRightLooksLeft = velocity.x > 0 && animator.scale.x < 0;
    if (goesLeftLooksRight || goesRightLooksLeft) {
      animator.flipHorizontally();
    }
  }
}
