import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/animators/default_npc_animator.dart';
import 'package:flame_nano_rpg/gen/assets.gen.dart';

final class EnemyOrcShamanAnimator extends DefaultNpcAnimator {
  EnemyOrcShamanAnimator({
    required super.position,
    required super.size,
    required super.anchor,
  });

  @override
  SpriteAnimation get idleAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.enemies.orcShaman.idle.keyName),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get walkAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.enemies.orcShaman.walk.keyName),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get attackAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.enemies.orcShaman.attack1.keyName),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get dieAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.enemies.orcShaman.dead.keyName),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get hurtAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache(Assets.images.enemies.orcShaman.hurt.keyName),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );
}
