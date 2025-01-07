import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/health_bar.dart';
import 'package:flame_nano_rpg/overlays/stamina_bar.dart';

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

  late final HealthBar _healthBar;
  late final StaminaBar _staminaBar;

  Player? _player;

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
    _healthBar = HealthBar(
      progress: 0,
      position: Vector2(game.size.x - 250, 20),
    );
    add(_healthBar);

    _staminaBar = StaminaBar(
      progress: 0,
      position: Vector2(game.size.x - 250, 45),
    );
    add(_staminaBar);

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
    // Find player if not set
    _player ??= game.findByKeyName('player');
    _healthBar.progress = _player!.health / _player!.maxHealth;
    _staminaBar.progress = _player!.stamina / _player!.maxStamina;
  }
}
