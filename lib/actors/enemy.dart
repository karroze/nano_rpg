import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

enum EnemyState {
  idle,
  walk,
  attack,
  hurt,
  die;
}

final class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef<NanoRpgGame>, KeyboardHandler, CollisionCallbacks {
  Enemy({
    required super.position,
  }) : super(
          size: Vector2(96, 96),
          anchor: Anchor.center,
        );

  static const double moveSpeed = 50;

  late final idleAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_berserk/idle.png'),
    SpriteAnimationData.sequenced(
      amount: 5,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final walkAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_berserk/walk.png'),
    SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: .2,
      textureSize: Vector2.all(96),
    ),
  );

  late final attackAnimation1 = SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_berserk/attack_1.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final dieAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_berserk/dead.png'),
    SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  late final hurtAnimation = SpriteAnimation.fromFrameData(
    game.images.fromCache('enemies/orc_berserk/hurt.png'),
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: .2,
      textureSize: Vector2.all(96),
      loop: false,
    ),
  );

  Vector2 velocity = Vector2.zero();

  final int maxHealth = 100;
  late int health = maxHealth;

  bool isAttacking = false;
  bool isAttacked = false;
  bool attackingInProgress = false;

  @override
  FutureOr<void> onLoad() {
    // Map states to animations
    animations = {
      EnemyState.idle: idleAnimation,
      EnemyState.walk: walkAnimation,
      EnemyState.attack: attackAnimation1,
      EnemyState.hurt: hurtAnimation,
      EnemyState.die: dieAnimation,
      // PlayerState.attack2: attackAnimation2,
      // PlayerState.attack3: attackAnimation3,
    };

    // Set attack animations tickers
    animationTickers?[EnemyState.attack]?.onComplete = () {
      isAttacking = false;
      attackingInProgress = false;
    };

    animationTickers?[EnemyState.hurt]?.onComplete = () {
      isAttacked = false;
      current = EnemyState.idle;
    };
    animationTickers?[EnemyState.die]?.onComplete = () async {
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
      removeFromParent();
    };
    // animationTickers?[PlayerState.attack2]?.onComplete = () {
    //   isAttacking = false;
    //   attackingInProgress = false;
    // };
    // animationTickers?[PlayerState.attack3]?.onComplete = () {
    //   isAttacking = false;
    //   attackingInProgress = false;
    // };

    // Add hitbox
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Update animation state
    if (!isAttacked) {
      if (isAttacking) {
        if (!attackingInProgress) {
          current = [EnemyState.attack].random();
          attackingInProgress = true;
        }
      } else {
        if (velocity.isZero()) {
          current = EnemyState.idle;
        } else {
          current = EnemyState.walk;
        }
      }
    }
    super.update(dt);
  }

  void receiveDamage({
    required int damage,
    required Vector2 targetScale,
  }) {
    health -= damage;
    isAttacked = true;
    if (health <= 0) {
      current = EnemyState.die;
    } else {
      current = EnemyState.hurt;
    }
  }

  void lookAtTarget(Vector2 target) {
    scale.x = -target.x;
  }
}
