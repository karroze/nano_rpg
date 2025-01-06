import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';

final class EnemyOrcShaman extends Enemy {
  EnemyOrcShaman({
    required super.position,
  }) : super(
    size: Vector2(96, 96),
  );

  @override
  double moveSpeed = 50;

  @override
  int get maxHealth => 100;

  @override
  SpriteAnimation get idleAnimation => SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_shaman/idle.png'),
    SpriteAnimationData.sequenced(
      amount: 5,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  @override
  SpriteAnimation get walkAnimation => SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_shaman/walk.png'),
    SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  @override
  SpriteAnimation get attackAnimation => SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_shaman/attack_1.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  @override
  SpriteAnimation get dieAnimation => SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_shaman/dead.png'),
    SpriteAnimationData.sequenced(
      amount: 5,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  @override
  SpriteAnimation get hurtAnimation => SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_shaman/hurt.png'),
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );
}
