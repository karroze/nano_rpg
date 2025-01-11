import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_npc_animator.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/health_bar.dart';
import 'package:flame_nano_rpg/worlds/main_world.dart';
import 'package:flutter/material.dart';

abstract class BaseNpcComponent<State> extends PositionComponent
    with
        HasGameRef<NanoRpgGame>,
        HasWorldReference<MainWorld>,
        Living,
        Moving,
        HasStamina,
        Interactable,
        Attackable,
        Attacking,
        AttackingWithCooldown,
        AttackingWithStamina {
  BaseNpcComponent({
    required super.position,
    required super.size,
    required super.anchor,
    super.key,
    super.priority,
  });

  /// Provide initialized [FriendlyNpcAnimator] for npc.
  FutureOr<SimpleCharacterAnimator<State>> provideAnimationGroupComponent();

  /// Provides [NpcAnimatorCallbacks].
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks();

  /// Provide [State] update upon every update for [dt].
  ///
  /// Return null if no state update is required.
  State? provideStateUpdate(double dt);

  /// Returns a list of [Attackable] targets to interact with
  List<BaseNpcComponent<Object>> filterTargets(List<BaseNpcComponent<Object>> foundTargets);

  /// Provide hitbox size.
  Vector2 get hitboxSize;

  int get visibilityRange;

  late List<BaseNpcComponent<Object>> availableTargets = <BaseNpcComponent<Object>>[];
  late final SimpleCharacterAnimator<State> animator;
  late final HealthBar healthBar;

  /// Flag if NPC is dead.
  bool isDead = false;

  @override
  @mustCallSuper
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Get animator and add to the component
    animator = await provideAnimationGroupComponent();
    // Set animator callbacks
    animator.animatorCallbacks = await provideAnimationCallbacks();
    // Add animator
    await add(animator);

    // Setup ui
    await setupUi();

    // Add hitbox
    await setupHitbox();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    // // Set vero velocity
    // velocity.setValues(
    //   0,
    //   0,
    // );

    // Handle stamina updated and movement if is alive
    if (isAlive) {
      // Handle stamina regeneration
      handleStamina(dt);
      // Handle attacking cooldown
      handleAttackingCooldown(dt);
      // Lookup targets
      handleTargetsLookup();
      // Handle NPC interactions
      handleInteractions(availableTargets);

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
    healthBar.value = health;
    // Update current animator state if update is not null
    final stateUpdate = provideStateUpdate(dt);

    if (stateUpdate != null && stateUpdate != animator.current) {
      animator.current = stateUpdate;
      // print(
      //   '''
      // \n
      // === === ===
      // $runtimeType
      //
      // OldState: ${animator.current}
      // NewState: $stateUpdate
      // === === ===
      //
      // ''',
      // );
    }

    // If not alive anymore and not dead already
    if (!isAlive && !isDead) {
      isDead = true;
      world.removeObjectFromMap(this);
    }
  }

  @override
  void handleWalkPoint(
    double dt, {
    required Vector2 walkPoint,
    required double endDistance,
  }) {
    super.handleWalkPoint(
      dt,
      walkPoint: walkPoint,
      endDistance: endDistance,
    );
    // Update object position on the map
    world.updateObjectFromMap(
      this,
      newPosition: position,
    );
  }

  @override
  void handleInteractions(List<BaseNpcComponent<Object>> targets) {
    // Do nothing if there are no targets
    if (availableTargets.isEmpty) return;

    // Iterate over targets starting from the last one
    for(final currentTarget in availableTargets.reversed) {
      // Switch target type
      final targetPosition = currentTarget.position;
      // Find distance
      final distanceToTarget = (targetPosition - position).length - (currentTarget.size / 4).length;
      // Interact with target
      final hasInteraction = interactWith(
        currentTarget,
        distance: distanceToTarget,
      );
      
      // Return from iteration over enemies if interaction happened
      if(hasInteraction) return;
    }
  }

  @override
  void lookAtTarget(
    Vector2 targetPosition,
  ) {
    // Do nothing if dead
    if (!isAlive) return;

    // Calculate new scale
    final newScaleX = switch (velocity.x) {
      > 0 => 1.0,
      < 0 => -1.0,
      _ => null,
    };

    // Change scale if new scale differs
    if (newScaleX != null) {
      animator.scale.x = newScaleX;
    }
  }

  /// Method to initialize npc UI.
  @mustCallSuper
  FutureOr<void> setupUi() async {
    // Initialize and add health bar above npc
    healthBar = HealthBar(
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
    await add(healthBar);
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

  /// Lookups possible targets, passes found items to [filterTargets] and assigns resulting list to [availableTargets].
  void handleTargetsLookup() {
    // Lookup targets for npc position and remove self
    final foundTargets = world.lookupObjectsForPosition(
      position,
      distance: visibilityRange,
    )..removeWhere((target) => target == this);
    // Assign filtered result to enemy targets
    availableTargets = filterTargets(foundTargets);
  }

  /// Handles attack with a [target].
  bool handleEnemy(
    BaseNpcComponent<Object> target, {
    required double distance,
  }) {
    // Get target position
    final targetPosition = target.position;
    // Get its position
    if (distance <= visibilityRange) {
      lookAtTarget(targetPosition);
    }

    if (distance > moveDistance && distance <= visibilityRange) {
      lookAtTarget(targetPosition);
      return false; // TODO(georgii.savatkov): Maybe?
    } else if (distance <= moveDistance && distance > attackRange) {
      setWalkTarget(
        target.position,
        endDistance: attackRange,
      );
      return true;
    } else if (distance <= attackRange && canAttack) {
      attackTarget(
        target: target,
      );
      return true;
    }

    // Return false if nothing happened
    return false;
  }

  FutureOr<void> onIdleStarted() {
    isAttacked = false;
  }

  FutureOr<void> onIdleEnded() => null;

  FutureOr<void> onAttackStarted() {
    isAttackingInProgress = true;
    isAttacked = false;
  }

  FutureOr<void> onAttackEnded() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  FutureOr<void> onDieStarted() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  FutureOr<void> onHurtStarted() async {
    isAttacking = false;
    isAttackingInProgress = false;
    await animator.add(
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
}
