import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/animators/npc_animator_callbacks.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';
import 'package:flame_nano_rpg/actors/interactors/npc_to_npc_interaction_handler/npc_to_npc_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/npc_to_player_interaction_handler/npc_to_player_interaction_handler.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/simple_npc_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_warrior/friendly_warrior_animator.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class FriendlyWarriorComponent extends SimpleNpcComponent {
  FriendlyWarriorComponent({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
          priority: 2,
        );

  Player? player;

  @override
  int get maxHealth => 250;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 20;

  @override
  int get staminaRegenPerTimeframe => 5;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  double get moveSpeed => 50;

  // --- Distances ---

  @override
  double get moveDistance => 100;

  @override
  int get visibilityDistance => 150;

  @override
  double get attackDistance => 25;

  @override
  double get interactionDistance => 25;

  // --- End Distances ---

  @override
  double get damageCooldownTimeframeSeconds => 2;

  // Dimensions
  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  @override
  List<Attack> get availableAttacks => [
        const Attack(
          title: 'Simple',
          damage: 20,
          damageCrit: 25,
          critChance: .15,
          range: 25,
        ),
      ];

  @override
  FutureOr<SimpleCharacterAnimator<NpcState>> provideAnimationGroupComponent() => FriendlyWarriorAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );

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
  FutureOr<void> onDieEnded() async {
    await animator.add(
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
    // await onDie();
    removeFromParent();
  }
}
