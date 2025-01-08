import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/contracts/enemy_npc.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_state.dart';

abstract class EnemyNpcDefaultAnimated extends EnemyNpc<EnemyState> {
  EnemyNpcDefaultAnimated({
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
      EnemyState.attack => _setupAttackAnimationTicker(ticker),
      EnemyState.hurt => _setupHurtAnimationTicker(ticker),
      EnemyState.die => _setupDieAnimationTicker(ticker),
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
