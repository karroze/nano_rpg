import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_berserk/enemy_orc_berserk_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class EnemyOrcBerserkComponent extends SimpleNpcComponent {
  EnemyOrcBerserkComponent({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  int get maxHealth => 250;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 50;

  @override
  int get staminaRegenPerTimeframe => 5;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  double get moveSpeed => 25;

  // --- Distances ---

  @override
  double get moveDistance => 100;

  @override
  double get attackDistance => 25;

  @override
  double get interactionDistance => 25;

  @override
  int get visibilityDistance => 150;

  // --- End Distances ---

  @override
  double get damageCooldownTimeframeSeconds => 2;

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
  FutureOr<SimpleCharacterAnimator<NpcState>> provideAnimationGroupComponent() => EnemyOrcBerserkAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );
}
