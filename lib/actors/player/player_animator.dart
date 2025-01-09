import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/animators/simple_character_animator.dart';
import 'package:flame_nano_rpg/actors/player/player_state.dart';

final class PlayerAnimator extends SimpleCharacterAnimator<PlayerState> {
  PlayerAnimator({
    required super.position,
    required super.size,
    required super.anchor,
  });

  late final idleAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/idle.png'),
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final walkAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/walk.png'),
    SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final attackAnimation1 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_1.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final attackAnimation2 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_2.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final attackAnimation3 = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/attack_3.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final hurtAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/hurt.png'),
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final dieAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('player/warrior_1/dead.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  @override
  FutureOr<Map<PlayerState, SpriteAnimation>> setupAnimations() {
    return {
      PlayerState.idle: idleAnimation,
      PlayerState.walk: walkAnimation,
      PlayerState.attack1: attackAnimation1,
      PlayerState.attack2: attackAnimation2,
      PlayerState.attack3: attackAnimation3,
      PlayerState.hurt: hurtAnimation,
      PlayerState.die: dieAnimation,
    };
  }

  @override
  FutureOr<void> setupAnimationTickers({
    required PlayerState state,
    required SpriteAnimationTicker ticker,
  }) {
    final _ = switch (state) {
      PlayerState.attack1 || PlayerState.attack2 || PlayerState.attack3 => setupAttackAnimationTicker(ticker),
      PlayerState.hurt => setupHurtAnimationTicker(ticker),
      PlayerState.die => setupDieAnimationTicker(ticker),
      _ => null,
    };
  }
}
