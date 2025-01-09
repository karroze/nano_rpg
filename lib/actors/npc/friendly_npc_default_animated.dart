import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/contracts/base_npc.dart';
import 'package:flame_nano_rpg/actors/contracts/friendly_npc.dart';
import 'package:flame_nano_rpg/actors/npc/npc_state.dart';

final class FriendlyWarAnimator extends FriendlyNpcAnimator {
  FriendlyWarAnimator({
    required super.position,
    required super.size,
    required super.anchor,
    required super.animatorCallbacks,
  });

  @override
  SpriteAnimation get idleAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('player/warrior_2/idle.png'),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get walkAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('player/warrior_2/walk.png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get attackAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('player/warrior_2/attack_1.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get dieAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('player/warrior_2/dead.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get hurtAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('player/warrior_2/hurt.png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );
}

final class FriendlyNpcAnimatorCallbacks {
  FriendlyNpcAnimatorCallbacks({
    this.onAttackStarted,
    this.onAttackEnded,
    this.onHurtStarted,
    this.onHurtEnded,
    this.onDieStarted,
    this.onDieEnded,
  });

  FutureOr<void> Function()? onAttackStarted;

  FutureOr<void> Function()? onAttackEnded;

  FutureOr<void> Function()? onHurtStarted;

  FutureOr<void> Function()? onHurtEnded;

  FutureOr<void> Function()? onDieStarted;

  FutureOr<void> Function()? onDieEnded;
}

abstract class FriendlyNpcAnimator extends CharacterAnimator<NpcState> {
  FriendlyNpcAnimator({
    required super.position,
    required super.size,
    required super.anchor,
    required this.animatorCallbacks,
  });

  SpriteAnimation get idleAnimation;

  SpriteAnimation get walkAnimation;

  SpriteAnimation get attackAnimation;

  SpriteAnimation get dieAnimation;

  SpriteAnimation get hurtAnimation;

  final FriendlyNpcAnimatorCallbacks animatorCallbacks;

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
      NpcState.attack => _setupAttackAnimationTicker(ticker),
      NpcState.hurt => _setupHurtAnimationTicker(ticker),
      NpcState.die => _setupDieAnimationTicker(ticker),
      _ => null,
    };
  }

  /// Sets attack animation ticker callbacks.
  FutureOr<void> _setupAttackAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks.onAttackStarted
      ..onComplete = animatorCallbacks.onAttackEnded;
  }

  /// Sets hurt animation ticker callbacks.
  FutureOr<void> _setupHurtAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks.onHurtStarted
      ..onComplete = animatorCallbacks.onHurtEnded;
  }

  /// Sets die animation ticker callbacks.
  FutureOr<void> _setupDieAnimationTicker(SpriteAnimationTicker ticker) {
    ticker
      ..onStart = animatorCallbacks.onDieStarted
      ..onComplete = animatorCallbacks.onDieEnded;
  }
}

abstract class FriendlyNpcDefaultAnimated extends FriendlyNpc<NpcState> {
  FriendlyNpcDefaultAnimated({
    required super.position,
    required super.size,
    required super.anchor,
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
      NpcState.attack => _setupAttackAnimationTicker(ticker),
      NpcState.hurt => _setupHurtAnimationTicker(ticker),
      NpcState.die => _setupDieAnimationTicker(ticker),
      _ => null,
    };
  }

  /// Sets attack animation ticker callbacks.
  FutureOr<void> _setupAttackAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker
      ..onStart = () async {
        isAttackingInProgress = true;
      }
      ..onComplete = () async {
        isAttacking = false;
        isAttackingInProgress = false;
      };
  }

  /// Sets hurt animation ticker callbacks.
  FutureOr<void> _setupHurtAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker
      ..onStart = () async {
        add(
          OpacityEffect.fadeOut(
            EffectController(
              alternate: true,
              duration: 0.125,
              repeatCount: 2,
            ),
          ),
        );
      }
      ..onComplete = () async {
        isAttacked = false;
        isAttacking = false;
        isAttackedInProgress = false;
      };
  }

  /// Sets die animation ticker callbacks.
  FutureOr<void> _setupDieAnimationTicker(SpriteAnimationTicker ticker) async {
    ticker.onComplete = () async {
      add(
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
      await onDie();
      removeFromParent();
    };
  }
}
