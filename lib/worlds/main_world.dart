import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class MainWorld extends World with HasGameRef<NanoRpgGame> {
  final gridSize = 50;

  @override
  FutureOr<void> onLoad() async {
    await _loadMap();
    await _loadPlayer();
    await _loadEnemies();

    game.camera
      ..viewfinder.anchor = Anchor.topLeft
      ..viewport.add(Hud());
    return super.onLoad();
  }

  FutureOr<void> _loadMap() async {
    final mapSizeX = (game.size.x / gridSize).ceil();
    final maxSizeY = (game.size.y / gridSize).ceil();
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
        position: game.size / 2,
      ),
    );
  }

  FutureOr<void> _loadEnemies() async {
    add(
      Enemy(
        position: game.size / 2 + Vector2(150, 0),
      ),
    );
  }
}
