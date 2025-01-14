import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/actors/player/player_animator.dart';
import 'package:flame_nano_rpg/actors/player/player_state.dart';
import 'package:flame_nano_rpg/objects/attack.dart';
import 'package:flutter/services.dart';

final class Player extends BaseNpcComponent<PlayerState> with KeyboardHandler, CollisionCallbacks, Healable {
  Player({
    required super.position,
  }) : super(
          key: ComponentKey.named('player'),
          priority: 1,
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  int get maxHealth => 1000;

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
  double get attackDistance => 25;

  @override
  double get interactionDistance => 25;

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

  @override
  int get visibilityDistance => 150;

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
  List<Interactable> filterTargets(List<Interactable> foundTargets) {
    // return foundTargets.whereType<SimpleNpcComponent>().toList();
    return foundTargets;
  }

  @override
  FutureOr<void> setupUi() {
    super.setupUi();
    // Remove health bar from player
    healthBar.removeFromParent();
  }

  /// Handles what animation to play.
  @override
  PlayerState? provideStateUpdate(double dt) {
    // Set dead if not alive
    if (!isAlive) {
      return PlayerState.die;
    }
    // print('Animation handling: isAlive: true');

    if (isAttacked) {
      // If there is an attacking in progress, do nothing
      if (isAttackedInProgress || isAttackingInProgress) return null;
      // Get new state
      return switch (isAlive) {
        true => PlayerState.hurt,
        false => PlayerState.die,
      };
    }

    // If attacking
    if (isAttacking) {
      // If there is an attacking in progress, do nothing
      if (isAttackingInProgress) return null;

      // Choose random attack animation
      return [PlayerState.attack1, PlayerState.attack2, PlayerState.attack3].random();
    }

    // Handle idle or walking
    return switch (velocity.isZero()) {
      true => PlayerState.idle,
      false => PlayerState.walk,
    };
  }

  @override
  bool interactWith(
    Interactable object, {
    required double distance,
  }) {
    return switch (object) {
      final SimpleNpcComponent enemy => handleEnemy(
          enemy,
          distance: distance,
        ),
      // final Eatable eatable => handleEatable(
      //     eatable,
      //     distance,
      //   ),
      _ => false,
    };
  }

  @override
  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  }) {
    return switch (other) {
      final Eatable eatable => HealInteractionHandler(
          eatable: eatable,
          target: this,
          payload: payload,
        ),
      _ => null,
    };
  }

  @override
  bool handleEnemy(
    BaseNpcComponent<Object> target, {
    required double distance,
  }) {
    // Get its position
    if (distance <= attackDistance && canAttack && isAttacking && !isAttackingInProgress) {
      attackTarget(
        target: target,
      );
      return true;
    }

    return false;
  }

  /// Handles interaction with [eatable] at given [distance].
  bool handleEatable(
    Eatable eatable,
    double distance,
  ) {
    // Check that within interaction distance
    if (distance > eatable.interactionDistance) return false;

    // Try to eat item
    final wasEaten = eatable.eatBy(this);
    // Apply effects if so
    // TODO(georgii.savatkov): Maybe move to animation callbacks?
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

    // Return whether interaction was made
    return wasEaten;
  }

  @override
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

    // Update object position on the map
    world.updateObjectFromMap(
      this,
      newPosition: position,
    );

    // Control flip
    final goesLeftLooksRight = velocity.x < 0 && animator.scale.x > 0;
    final goesRightLooksLeft = velocity.x > 0 && animator.scale.x < 0;
    if (goesLeftLooksRight || goesRightLooksLeft) {
      animator.flipHorizontally();
    }
  }
}
