import 'dart:async';

import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/enemy_state.dart';

abstract class EnemyNpcAnimator extends SimpleCharacterAnimator<EnemyState> {
  EnemyNpcAnimator({
    required super.position,
    required super.size,
    required super.anchor,
    super.animatorCallbacks,
  });

  SpriteAnimation get idleAnimation;

  SpriteAnimation get walkAnimation;

  SpriteAnimation get attackAnimation;

  SpriteAnimation get dieAnimation;

  SpriteAnimation get hurtAnimation;

  @override
  Map<EnemyState, SpriteAnimation> setupAnimations() {
    return {
      EnemyState.idle: idleAnimation,
      EnemyState.walk: walkAnimation,
      EnemyState.attack: attackAnimation,
      EnemyState.hurt: hurtAnimation,
      EnemyState.die: dieAnimation,
    };
  }

  @override
  FutureOr<void> setupAnimationTickers({
    required EnemyState state,
    required SpriteAnimationTicker ticker,
  }) {
    final _ = switch (state) {
      EnemyState.attack => setupAttackAnimationTicker(ticker),
      EnemyState.hurt => setupHurtAnimationTicker(ticker),
      EnemyState.die => setupDieAnimationTicker(ticker),
      _ => null,
    };
  }
}
