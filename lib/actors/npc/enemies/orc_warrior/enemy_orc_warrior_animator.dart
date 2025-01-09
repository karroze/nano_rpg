import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/enemy_npc_animator.dart';

final class EnemyOrcWarriorAnimator extends EnemyNpcAnimator {
  EnemyOrcWarriorAnimator({
    required super.position,
    required super.size,
    required super.anchor,
  });

  @override
  SpriteAnimation get idleAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/orc_warrior/idle.png'),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get walkAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/orc_warrior/walk.png'),
        SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: .2,
          textureSize: Vector2.all(96),
        ),
      );

  @override
  SpriteAnimation get attackAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/orc_warrior/attack_1.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get dieAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/orc_warrior/dead.png'),
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );

  @override
  SpriteAnimation get hurtAnimation => SpriteAnimation.fromFrameData(
        game.images.fromCache('enemies/orc_warrior/hurt.png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: .2,
          textureSize: Vector2.all(96),
          loop: false,
        ),
      );
}
