import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/health_bar.dart';
import 'package:flame_nano_rpg/overlays/progress_bar.dart';
import 'package:flame_nano_rpg/overlays/stamina_bar.dart';
import 'package:flutter/material.dart';

final class Hud extends PositionComponent with HasGameRef<NanoRpgGame> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late TextComponent _scoreTextComponent;

  @override
  FutureOr<void> onLoad() async {
    // _scoreTextComponent = TextComponent(
    //   text: 'Score: 0',
    //   textRenderer: TextPaint(
    //     style: const TextStyle(
    //       fontSize: 32,
    //       color: Colors.white,
    //     ),
    //   ),
    //   anchor: Anchor.bottomLeft,
    //   position: Vector2(
    //     20,
    //     game.size.y - 20,
    //   ),
    // );
    // add(_scoreTextComponent);

    // add(
    //   HealthComponent(
    //     position: Vector2(
    //       game.size.x - 150,
    //       20,
    //     ),
    //   ),
    // );

    add(
      HealthBar(
        position: Vector2(game.size.x - 250, 20),
      ),
    );

    add(
      StaminaBar(
        position: Vector2(game.size.x - 250, 45),
      ),
    );

    add(
      FpsTextComponent(
        position: Vector2(
          20,
          20,
        ),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // final score = game.score.clamp(
    //   0,
    //   double.nan,
    // );
    // _scoreTextComponent.text = 'Score: $score';
  }
}
