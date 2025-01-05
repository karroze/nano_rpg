import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bar.dart';
import 'package:flutter/material.dart';

final class HealthBar extends PositionComponent with HasGameRef<NanoRpgGame> {
  HealthBar({
    required super.position,
  }) : super(
          size: Vector2(100, 20),
          anchor: Anchor.topLeft,
        );

  late final TextComponent _labelTextComponent;
  late final ProgressBar _healthProgressBar;

  @override
  FutureOr<void> onLoad() {
    _labelTextComponent = TextComponent(
      text: 'Health:',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: position,
    );
    game.add(_labelTextComponent);
    
    _healthProgressBar = ProgressBar(
      progress: game.playerHealth / game.playerMaxHealth,
      progressColor: Colors.red,
      bgColor: Colors.white,
      position: position + Vector2(_labelTextComponent.size.x + 5, 4),
      size: size,
      anchor: Anchor.centerLeft,
    );

    game.add(_healthProgressBar);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _healthProgressBar.progress = game.playerHealth / game.playerMaxHealth;
    super.update(dt);
  }
}
