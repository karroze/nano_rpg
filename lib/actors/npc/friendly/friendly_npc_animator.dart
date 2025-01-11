import 'dart:async';

import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/npc_state.dart';

abstract class FriendlyNpcAnimator extends SimpleCharacterAnimator<NpcState> {
  FriendlyNpcAnimator({
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
  Map<NpcState, SpriteAnimation> setupAnimations() {
    return {
      NpcState.idle: idleAnimation,
      NpcState.walk: walkAnimation,
      NpcState.attack: attackAnimation,
      NpcState.hurt: hurtAnimation,
      NpcState.die: dieAnimation,
    };
  }

  @override
  FutureOr<void> setupAnimationTickers({
    required NpcState state,
    required SpriteAnimationTicker ticker,
  }) {
    final _ = switch (state) {
      NpcState.idle => setupIdleAnimationTicker(ticker),
      NpcState.attack => setupAttackAnimationTicker(ticker),
      NpcState.hurt => setupHurtAnimationTicker(ticker),
      NpcState.die => setupDieAnimationTicker(ticker),
      _ => null,
    };
  }
}
