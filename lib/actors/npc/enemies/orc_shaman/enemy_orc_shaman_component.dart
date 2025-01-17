import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_shaman/enemy_orc_shaman_animator.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';
import 'package:flame_nano_rpg/actors/npc/simple_npc_component.dart';
import 'package:flame_nano_rpg/objects/attack.dart';
import 'package:flame_nano_rpg/objects/fraction.dart';

final class EnemyOrcShamanComponent extends SimpleNpcComponent {
  EnemyOrcShamanComponent({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  @override
  int get maxHealth => 100;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 20;

  @override
  int get staminaRegenPerTimeframe => 10;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  double get moveSpeed => 50;

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
  double get damageCooldownTimeframeSeconds => 1.5;

  @override
  Vector2 get hitboxSize => Vector2(68, 64);

  @override
  Fraction get fraction => Fraction.enemy;

  @override
  List<Attack> get availableAttacks => [
        const Attack(
          title: 'Simple',
          damage: 10,
          damageCrit: 15,
          critChance: .3,
          range: 25,
        ),
      ];

  @override
  FutureOr<SimpleCharacterAnimator<NpcState>> provideAnimationGroupComponent() => EnemyOrcShamanAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );
}
