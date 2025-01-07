import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';

final class EnemyOrcWarrior extends Enemy {
  EnemyOrcWarrior({
    required super.position,
  }) : super(
    size: Vector2(96, 96),
  );

  @override
  double moveSpeed = 50;

  @override
  int get maxHealth => 100;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 20;

  @override
  int get staminaRegenPerTimeframe => 10;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  int get damage => 20;

  @override
  double get damageCooldownTimeframeSeconds => 2;

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
