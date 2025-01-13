import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/layout.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/health_bar.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/labeled_progress_bar.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/stamina_bar.dart';
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

  late final LabeledProgressBar _healthBar;
  late final StaminaBar _staminaBar;

  Player? _player;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    await add(
      AlignComponent(
        child: HudBackgroundComponent(
          position: Vector2.zero(),
          size: Vector2(300, 55),
          anchor: Anchor.center,
        ),
        alignment: Anchor.center,
        keepChildAnchor: true,
      ),
    );

    _healthBar = HealthBar(
      value: 0,
      maxValue: 0,
      position: Vector2(-110, 0),
      anchor: Anchor.centerLeft,
      showLabel: false,
    );
    await add(_healthBar);

    _staminaBar = StaminaBar(
      value: 0,
      maxValue: 0,
      position: Vector2(10, 0),
      anchor: Anchor.centerLeft,
      showLabel: false,
    );
    await add(_staminaBar);
  }

  @override
  void update(double dt) {
    // Find player if not set
    _player ??= game.findByKeyName('player');
    if (_player != null) {
      _healthBar
        ..value = _player!.health
        ..maxValue = _player!.maxHealth;
      _staminaBar
        ..value = _player!.stamina
        ..maxValue = _player!.maxStamina;
    }
  }
}

final class HudBackgroundComponent extends PositionComponent {
  HudBackgroundComponent({
    required super.position,
    required super.size,
    required super.anchor,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = Colors.white10
        ..style = PaintingStyle.fill,
    );
  }
}
