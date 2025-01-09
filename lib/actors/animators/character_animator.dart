import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';

abstract class CharacterAnimator<State> extends SpriteAnimationGroupComponent<State> with HasGameRef<NanoRpgGame> {
  CharacterAnimator({
    required super.position,
    required super.size,
    required super.anchor,
    super.key,
  });

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
  }
}
