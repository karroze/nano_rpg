import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/eatable.dart';
import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/eat_interaction_handler/eat_interaction_handler_callbacks.dart';
import 'package:flame_nano_rpg/actors/interactors/heal_interaction_handler/heal_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';
import 'package:flame_nano_rpg/actors/interactors/player_attack_interaction_handler/player_attack_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/simple_npc_component.dart';
import 'package:flame_nano_rpg/actors/player/player_animator.dart';
import 'package:flame_nano_rpg/actors/player/player_state.dart';
import 'package:flame_nano_rpg/objects/attack.dart';
import 'package:flame_nano_rpg/objects/fraction.dart';
import 'package:flame_nano_rpg/objects/healing.dart';
import 'package:flutter/services.dart';

final class Player extends BaseNpcComponent<PlayerState> with KeyboardHandler, CollisionCallbacks, Healable, Healer {
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
  Healing produceHealing() => const Healing(
        amount: 100,
      );

  @override
  double get damageCooldownTimeframeSeconds => 0;

  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  @override
  int get visibilityDistance => 150;

  /// [Vector2] to store last collision direction.
  late final collisionDirection = Vector2.zero();

  /// Callbacks for [EatInteractionHandler].
  late final eatInteractionHandlerCallbacks = EatInteractionHandlerCallbacks()..onEatableConsumed = _onEatableConsumed;

  @override
  FutureOr<SimpleCharacterAnimator<PlayerState>> provideAnimationGroupComponent() => PlayerAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );

  @override
  @override
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks() => NpcAnimatorCallbacks()
    ..onIdleStarted = onIdleStarted
    ..onIdleEnded = onIdleStarted
    ..onAttackStarted = onAttackStarted
    ..onAttackEnded = onAttackEnded
    ..onHurtStarted = onHurtStarted
    ..onHurtEnded = onHurtEnded
    ..onDieEnded = onDieEnded;

  @override
  Fraction get fraction => Fraction.friend;

  @override
  List<Interactable> filterTargets(List<Interactable> foundTargets) => foundTargets;

  @override
  void update(double dt) {
    super.update(dt);
    // Handle movement if is alive
    if (isAlive) {
      _handleUpdateMovement(dt);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Check that player is alive
    if (!isAlive) return super.onKeyEvent(event, keysPressed);

    final key = event.logicalKey;

    final handledMovement = _handleMovement(keysPressed);
    // final handledCollision = _handleCollisionDirection();
    final handledAttacking = _handleInteractionButtonPressed(key);

    final handled = handledMovement || handledAttacking;

    // Propagate handler further if no action was performed
    if (!handled) return false;

    return true;
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
  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  }) {
    return switch (other) {
      final Healable attackable => HealInteractionHandler(
        healer: this,
        target: attackable,
        payload: payload,
      ),
      final Attackable attackable => PlayerAttackInteractionHandler(
          player: this,
          target: attackable,
          payload: payload,
        ),
      final Eatable eatable => EatInteractionHandler(
          eatable: eatable,
          target: this,
          payload: payload,
        )..callbacks = eatInteractionHandlerCallbacks,
      _ => null,
    };
  }

  /// Handles movement by processing keyboard [keysPressed]-s.
  ///
  /// Returns true if movement was handled.
  bool _handleMovement(Set<LogicalKeyboardKey> keysPressed) {
    // Check for X movement
    final velocityX = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft) => -1.0,
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight) => 1.0,
      _ => 0.0,
    };

    // Check for Y movement
    final velocityY = switch (keysPressed) {
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp) => -1.0,
      final Set<LogicalKeyboardKey> keys when keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown) => 1.0,
      _ => 0.0,
    };

    velocity.setValues(
      velocityX,
      velocityY,
    );
    return true;
  }

  /// Handles attacking
  bool _handleInteractionButtonPressed(LogicalKeyboardKey key) {
    // Check if attack button was pressed
    final shouldAttack = key == LogicalKeyboardKey.keyE;
    final shouldInteract = key == LogicalKeyboardKey.keyF;
    // Set flags if attacking
    if (shouldAttack) {
      isAttacking = true;
      isInteracting = true;
    } else {
      isInteracting = false;
    }
    // Set flags if is interacting
    if (shouldInteract) {
      isInteracting = true;
    } else {
      isInteracting = false;
    }
    return shouldAttack || shouldInteract;
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

  /// Handles successful eatable consumption.
  FutureOr<void> _onEatableConsumed(Eatable eatable) async {
    // Add scale effect to player's animator
    await animator.add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          alternate: true,
          duration: 0.125,
          repeatCount: 2,
        ),
      ),
    );
    // Remove eatable from the map
    world.mapResolver.removeObjectFromMap(eatable);
    // Remove eatable
    eatable.removeFromParent();
  }
}
