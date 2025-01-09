import 'dart:async';

import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/animators/character_animator.dart';
import 'package:flame_nano_rpg/actors/contracts/npc_animator_callbacks.dart';

abstract class BasicNpcAnimator<State> extends CharacterAnimator<State> {
  BasicNpcAnimator({
    required super.position,
    required super.size,
    required super.anchor,
    this.animatorCallbacks,
  });

  NpcAnimatorCallbacks? animatorCallbacks;

  /// Sets attack animation ticker callbacks.
  FutureOr<void> setupAttackAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks?.onAttackStarted
      ..onComplete = animatorCallbacks?.onAttackEnded;
  }

  /// Sets hurt animation ticker callbacks.
  FutureOr<void> setupHurtAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks?.onHurtStarted
      ..onComplete = animatorCallbacks?.onHurtEnded;
  }

  /// Sets die animation ticker callbacks.
  FutureOr<void> setupDieAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks?.onDieStarted
      ..onComplete = animatorCallbacks?.onDieEnded;
  }
}