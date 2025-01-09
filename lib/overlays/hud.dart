import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/health_bar.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/labeled_progress_bar.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/stamina_bar.dart';

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
    _healthBar = HealthBar(
      value: 0,
      maxValue: 0,
      position: Vector2(game.size.x - 250, 20),
      anchor: Anchor.center,
    );
    await add(_healthBar);

    _staminaBar = StaminaBar(
      value: 0,
      maxValue: 0,
      position: Vector2(game.size.x - 250, 45),
      anchor: Anchor.center,
    );
    await add(_staminaBar);

    await add(
      FpsTextComponent(
        position: Vector2(
          20,
          20,
        ),
      ),
    );
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
