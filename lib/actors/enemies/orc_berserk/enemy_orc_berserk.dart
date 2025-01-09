import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/basic_npc_animator.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';
import 'package:flame_nano_rpg/actors/enemies/orc_berserk/enemy_orc_berserk_animator.dart';
import 'package:flame_nano_rpg/actors/enemies/simple_enemy_component.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

final class EnemyOrcBerserkComponent extends SimpleEnemyComponent {
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
        critChance: .15,
        range: 25,
      );

  @override
  Attack chooseAttack() => _simpleAttack;

  @override
  FutureOr<BasicNpcAnimator<EnemyState>> provideAnimationGroupComponent() => EnemyOrcBerserkAnimator(
        position: size / 2,
        size: size,
        anchor: Anchor.center,
      );
}
