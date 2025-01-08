import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/npc/friendly_npc_regular.dart';

final class FriendlyWarrior extends FriendlyNpcRegular {
  FriendlyWarrior({
    required super.position,
  }) : super(
    size: Vector2(96, 96),
    anchor: Anchor.center,
  );

  @override
  int get maxHealth => 250;

  @override
  int get maxStamina => 100;

  @override
  int get staminaPerHit => 20;

  @override
  int get staminaRegenPerTimeframe => 5;

  @override
  double get staminaRegenTimeframeSeconds => 1;

  @override
  double get moveSpeed => 25;

  @override
  double get moveDistance => 100;

  @override
  double get attackRange => 25;

  @override
  int get damageAmount => 20;

  @override
  int get critDamageAmount => 25;

  @override
  double get critChance => .15;

  @override
  double get damageCooldownTimeframeSeconds => 2;

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