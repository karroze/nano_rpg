import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/contracts/friendly_npc.dart';
import 'package:flame_nano_rpg/actors/npc/npc_state.dart';

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
