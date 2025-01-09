import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/basic_npc_animator.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/enemies/orc_shaman/enemy_orc_shaman_animator.dart';
import 'package:flame_nano_rpg/actors/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class EnemyOrcShaman extends SimpleEnemyComponent {
  EnemyOrcShaman({
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

  @override
  double get moveDistance => 100;

  @override
  double get attackRange => 25;

  @override
  double get damageCooldownTimeframeSeconds => 1.5;

  @override
  List<Attack> get availableAttacks => [
        _simpleAttack,
      ];

  Attack get _simpleAttack => const Attack(
        title: 'Simple',
        damage: 10,
        damageCrit: 15,
        critChance: .3,
        range: 25,
      );

  @override
  Attack chooseAttack() => _simpleAttack;

  @override
  FutureOr<BasicNpcAnimator<EnemyState>> provideAnimationGroupComponent() => EnemyOrcShamanAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );
}
