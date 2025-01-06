import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/enemy_orc_berserk.dart';
import 'package:flame_nano_rpg/actors/enemy_orc_shaman.dart';
import 'package:flame_nano_rpg/actors/enemy_orc_warrior.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/actors/tree.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class MainWorld extends World with HasGameRef<NanoRpgGame> {
  final gridSize = 96;

  static const xOffset = 60;
  static const yOffset = 60;

  final map = <List<PositionComponent?>>[];

  @override
  FutureOr<void> onLoad() async {
    await _loadMap();
    await _loadPlayer();

    game.camera
      ..viewfinder.anchor = Anchor.topLeft
      ..viewport.add(Hud());

    return super.onLoad();
  }

  FutureOr<void> _loadMap() async {
    // Get number of X and Y grid cells
    final mapSizeX = (game.size.x / gridSize).ceil();
    final maxSizeY = (game.size.y / gridSize).ceil();

    // Iterate over
    for (var i = 0; i < mapSizeX - 1; i++) {
      // Add en empty list of maxSizeY size
      map.add(
        List.filled(
          maxSizeY,
          null,
        ),
      );
      for (var j = 0; j < maxSizeY - 1; j++) {
        final xPosition = xOffset + i * gridSize.toDouble();
        final yPosition = yOffset + j * gridSize.toDouble();

        final spawnPosition = Vector2(xPosition, yPosition);

        final objectToSpawn = switch (Random().nextInt(5000)) {
          < 1000 => Tree(
              position: spawnPosition,
            ),
          < 2500 => [
              EnemyOrcBerserk(
                position: spawnPosition,
              ),
              EnemyOrcShaman(
                position: spawnPosition,
              ),
              EnemyOrcWarrior(
                position: spawnPosition,
              ),
            ].random(),
          _ => null,
        };
        if (objectToSpawn != null) {
          map[i][j] = objectToSpawn;
          game.add(objectToSpawn);
        }
      }
    }
  }

  FutureOr<void> _loadPlayer() async {
    game.add(
      Player(
        position: game.size / 2,
      ),
    );
  }
}
