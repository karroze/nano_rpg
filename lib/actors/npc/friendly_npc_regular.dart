import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/enemy_npc.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';
import 'package:flame_nano_rpg/actors/npc/friendly_npc_default_animated.dart';
import 'package:flame_nano_rpg/actors/npc/npc_state.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/health_bar.dart';
import 'package:flutter/material.dart';

abstract class BaseNpcComponent extends PositionComponent
    with HasGameRef<NanoRpgGame>, Living, Moving, HasStamina, Attackable, Attacking, AttackingWithCooldown, AttackingWithStamina {
  BaseNpcComponent({
    required super.position,
    required super.size,
    required super.anchor,
  });

  /// Provide initialized [FriendlyNpcAnimator] for npc.
  FutureOr<FriendlyNpcAnimator> provideAnimationGroupComponent();

  /// Provide [NpcState] update upon every update for [dt].
  ///
  /// Return null if no state update is required.
  NpcState? provideStateUpdate(double dt);

  /// Handle NPC interactions with other objects.
  void handleInteractions();

  /// Provide hitbox size.
  Vector2 get hitboxSize;

  late final FriendlyNpcAnimator _npcAnimator;
  late final HealthBar _healthBar;

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Get animator and add to the component
    _npcAnimator = await provideAnimationGroupComponent();
    await add(_npcAnimator);

    // Setup ui
    await setupUi();

    // Add hitbox
    await setupHitbox();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    // Set vero velocity
    velocity.setValues(
      0,
      0,
    );

    // Handle stamina updated and movement if is alive
    if (isAlive) {
      // Handle stamina regeneration
      handleStamina(dt);
      // Handle attacking cooldown
      handleAttackingCooldown(dt);

      // Handle NPC interactions
      handleInteractions();

      // If there is a walk point
      if (walkPoint != null && !isAttacking) {
        handleWalkPoint(
          dt,
          walkPoint: walkPoint!,
          endDistance: attackRange,
        );
      }
    }

    // Update health bar value and position
    _healthBar.value = health;
    // Update current animator state if update is not null
    final stateUpdate = provideStateUpdate(dt);
    if(stateUpdate != null) {
      _npcAnimator.current = stateUpdate;
    }
  }

  @override
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

    // Change scale if new scale differs
    if (_npcAnimator.scale.x != newScaleX) {
      _npcAnimator.scale.x = newScaleX;
    }
  }

  /// Method to initialize npc UI.
  @mustCallSuper
  FutureOr<void> setupUi() async {
    // Initialize and add health bar above npc
    _healthBar = HealthBar(
      size: Vector2(50, 10),
      value: health,
      maxValue: maxHealth,
      position: Vector2(
        size.x / 2,
        25,
      ),
      showLabel: false,
      valueTextStyle: const TextStyle(
        fontSize: 8,
        color: Colors.black,
      ),
      anchor: Anchor.center,
    );
    await add(_healthBar);
  }

  /// Method to setup hitbox for the npc.
  ///
  /// By default used [RectangleHitbox] with a [hitboxSize].
  ///
  /// If hitbox should be custom, override this method.
  FutureOr<void> setupHitbox() async {
    await add(
      RectangleHitbox(
        size: hitboxSize,
        position: Vector2(
          size.x / 2,
          size.y,
        ),
        anchor: Anchor.bottomCenter,
      ),
    );
  }
}
