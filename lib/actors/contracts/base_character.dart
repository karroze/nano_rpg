import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

abstract class BaseCharacterAnimation<State> extends SpriteAnimationGroupComponent<State> with HasGameRef<NanoRpgGame>, Living {
  BaseCharacterAnimation({
    required super.position,
    required super.size,
    required super.anchor,
    super.key,
  });

  // Dimensions

  /// Method to provide a map of [State]] to [SpriteAnimation] entries.
  FutureOr<Map<State, SpriteAnimation>> setupAnimations();

  /// Method to setup animation tickers
  FutureOr<void> setupAnimationTickers({
    required State state,
    required SpriteAnimationTicker ticker,
  });

  FutureOr<void> onDie() => null;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Setup animations
    animations = await setupAnimations();
    // Iterate over tickers
    for (final MapEntry(key: state, value: _) in animations!.entries) {
      // And their tickers
      await setupAnimationTickers(
        state: state,
        ticker: animationTickers![state]!,
      );
    }

    // TODO(georgii.savatkov): This is trash but needed now
    // Add hitbox
    add(
      RectangleHitbox(
        size: Vector2(68, 64),
        position: Vector2(
          size.x / 2,
          size.y,
        ),
        anchor: Anchor.bottomCenter,
      ),
    );
  }
}
