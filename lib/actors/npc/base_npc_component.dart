import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_nano_rpg/actors/animators/default_npc_animator.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/contracts/interacting.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';
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
        Interacting,
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

  /// Provide initialized [DefaultNpcAnimator] for npc.
  FutureOr<SimpleCharacterAnimator<State>> provideAnimationGroupComponent();

  /// Provides [NpcAnimatorCallbacks].
  FutureOr<NpcAnimatorCallbacks?> provideAnimationCallbacks();

  /// Provide [State] update upon every update for [dt].
  ///
  /// Return null if no state update is required.
  State? provideStateUpdate(double dt);

  /// Returns a list of [BaseNpcComponent] targets to interact with
  List<Interactable> filterTargets(List<Interactable> foundTargets);

  /// Hitbox [Vector2] size for the NPC.
  Vector2 get hitboxSize;

  /// Visibility [int] range for NPC in pixels.
  int get visibilityDistance;

  /// List of current targets available to the NPC.
  late List<Interactable> availableTargets = <Interactable>[];

  /// Assigned animator
  late final SimpleCharacterAnimator<State> animator;

  /// Assigned [HealthBar] ui component.
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
          endDistance: attackDistance,
        );
      }
    }

    // Update health bar value and position
    healthBar.value = health;
    // Update current animator state if update is not null
    final stateUpdate = provideStateUpdate(dt);

    // If there is a state change, set new state
    if (stateUpdate != null && stateUpdate != animator.current) {
      animator.current = stateUpdate;
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

  void handleInteractions(List<Interactable> targets) {
    // Do nothing if there are no targets
    if (availableTargets.isEmpty) return;

    // Iterate over targets starting from the last one
    for (final currentTarget in availableTargets.reversed) {
      // Switch target type
      final targetPosition = currentTarget.position;
      // Calculate interaction offset based on size
      final distanceOffsetX = currentTarget.position.x > position.x ? size.x / 4 : currentTarget.size.x / 4;
      final distanceOffsetY = currentTarget.position.y > position.y ? size.y / 4 : currentTarget.size.y / 4;

      // Find distance
      final distanceToTarget = (targetPosition - position).length - Vector2(distanceOffsetX, distanceOffsetY).length;
      // Interact with target
      final hasInteraction = provideInteraction(
            currentTarget,
            payload: InteractionPayload(
              distance: distanceToTarget,
            ),
          )?.performInteraction() ??
          false;

      // Return from iteration over enemies if interaction happened
      if (hasInteraction) return;
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

    // Change scale if new scale is set
    if (newScaleX != null) {
      animator.scale.x = newScaleX;
    }
  }

  /// Lookups possible targets, passes found items to [filterTargets] and assigns resulting list to [availableTargets].
  void handleTargetsLookup() {
    // Lookup targets for npc position and remove self
    final foundTargets = world.lookupObjectsForPosition(
      position,
      distance: visibilityDistance,
    )..removeWhere((target) => target == this);
    // Assign filtered result to enemy targets
    availableTargets = filterTargets(foundTargets);
  }

  /// Handles interaction with a [target].
  ///
  /// [distance] can be used to determine what type of interaction to perform.
  bool handleEnemy(
    BaseNpcComponent<Object> target, {
    required double distance,
  }) {
    // Get target position
    final targetPosition = target.position;

    // Look at enemy if within visibility range but not within move range
    if (distance > moveDistance && distance <= visibilityDistance) {
      lookAtTarget(targetPosition);
      return false;
    }
    // Set walk target to the enemy if within move range but not within attack range
    else if (distance <= moveDistance && distance > attackDistance) {
      setWalkTarget(
        target.position,
        endDistance: attackDistance,
      );
      return true;
    }
    // Attack enemy if within attack range and can attack
    else if (distance <= attackDistance && canAttack) {
      attackTarget(
        target: target,
      );
      return true;
    }

    // Return false if nothing happened
    return false;
  }

  /// Animation callback when idle animation has started.
  FutureOr<void> onIdleStarted() {
    isAttacked = false;
    isAttackingInProgress = false;
  }

  /// Animation callback when idle animation has ended.
  FutureOr<void> onIdleEnded() => null;

  /// Animation callback when attack animation has started.
  FutureOr<void> onAttackStarted() {
    isAttackingInProgress = true;
    isAttacked = false;
  }

  /// Animation callback when attack animation has ended.
  FutureOr<void> onAttackEnded() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  /// Animation callback when die animation has started.
  FutureOr<void> onDieStarted() {
    isAttacking = false;
    isAttackingInProgress = false;
  }

  /// Animation callback when die animation has ended.
  FutureOr<void> onDieEnded() => null;

  /// Animation callback when hurt animation has started.
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

  /// Animation callback when hurt animation has ended.
  FutureOr<void> onHurtEnded() {
    isAttacked = false;
    isAttacking = false;
    isAttackedInProgress = false;
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
}
