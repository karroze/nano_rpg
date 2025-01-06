import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class NanoRpgGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  final playerMaxHealth = 100;
  final playerMaxStamina = 100;

  final playerStaminaPerHit = 25;
  final playerStaminaRegenPerTimeframe = 10;

  final gridSize = 50;

  late int playerHealth = playerMaxHealth;
  late int playerStamina = playerMaxStamina;

  double staminaRegenTime = 1;

  @override
  FutureOr<void> onLoad() async {
    await _loadAssets();
    await _loadMap();
    await _loadPlayer();
    await _loadEnemies();

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport.add(Hud());

    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    // Load assets
    await images.loadAll(
      [
        'explosion.png',
        'player/warrior_1/idle.png',
        'player/warrior_1/walk.png',
        'player/warrior_1/attack_1.png',
        'player/warrior_1/attack_2.png',
        'player/warrior_1/attack_3.png',
        'enemies/orc_berserk/idle.png',
        'enemies/orc_berserk/walk.png',
        'enemies/orc_berserk/attack_1.png',
        'enemies/orc_berserk/dead.png',
        'enemies/orc_berserk/hurt.png',
        'trees/tree/tree_1.png',
        'trees/tree/tree_2.png',
        'trees/tree/tree_3.png',
      ],
    );
  }

  @override
  void update(double dt) {
    staminaRegenTime -= dt;
    if (staminaRegenTime <= 0 && playerStamina < playerMaxStamina) {
      staminaRegenTime = 1;
      playerStamina += playerStaminaRegenPerTimeframe;
      playerStamina = playerStamina.clamp(0, playerMaxStamina);
    }
    super.update(dt);
  }

  FutureOr<void> _loadMap() async {
    final mapSizeX = (size.x / gridSize).ceil();
    final maxSizeY = (size.y / gridSize).ceil();
    for (var i = 1; i < mapSizeX - 1; i++) {
      for (var j = 1; j < maxSizeY - 1; j++) {
        final random = Random().nextInt(5000);
        if (random < 50) {
          add(
            Enemy(
              position: Vector2(
                i * gridSize.toDouble(),
                j * gridSize.toDouble(),
              ),
            ),
          );
        }
      }
    }
  }

  FutureOr<void> _loadPlayer() async {
    add(
      Player(
        position: size / 2,
      ),
    );
  }

  FutureOr<void> _loadEnemies() async {
    add(
      Enemy(
        position: size / 2 + Vector2(150, 0),
      ),
    );
  }
}
