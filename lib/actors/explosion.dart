import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

final class Explosion extends SpriteAnimationComponent with HasGameRef<NanoRpgGame> {
  Explosion({
    required super.position,
  }) : super(
          size: Vector2.all(96),
          anchor: Anchor.center,
          removeOnFinish: true,
        );

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('explosion.png'),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );

    animationTicker?.onComplete = removeFromParent;

    return super.onLoad();
  }
}
