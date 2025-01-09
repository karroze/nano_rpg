import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_warrior/enemy_orc_warrior_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class EnemyOrcWarriorComponent extends SimpleEnemyComponent {
  EnemyOrcWarriorComponent({
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
  double get moveSpeed => 35;

  @override
  double get moveDistance => 100;

  @override
  double get attackRange => 25;

  @override
  double get damageCooldownTimeframeSeconds => 2;

  @override
  List<Attack> get availableAttacks => [
        _simpleAttack,
      ];

  Attack get _simpleAttack => const Attack(
        title: 'Simple',
        damage: 20,
        damageCrit: 25,
        critChance: .2,
        range: 25,
      );

  @override
  Attack chooseAttack() => _simpleAttack;

  @override
  FutureOr<SimpleCharacterAnimator<EnemyState>> provideAnimationGroupComponent() => EnemyOrcWarriorAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );
}
