import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/enemy.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/actors/tree.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class MainWorld extends World with HasGameRef<NanoRpgGame> {
  final gridSize = 96;

  final map = <List<PositionComponent?>>[];

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
    for (var i = 0; i < mapSizeX - 1; i++) {
      map.add([]);
      for (var j = 0; j < maxSizeY - 1; j++) {
        map[i].add(null);
        final random = Random().nextInt(5000);
        if (random < 200) {
          final tree = Tree(
            position: Vector2(
              (i + 1) * gridSize.toDouble(),
              (j + 1) * j * gridSize.toDouble(),
            ),
          );
          map[i][j] = tree;
          add(tree);
        }
        else if (random < 500) {
          final enemy = Enemy(
            position: Vector2(
              (i + 1) * gridSize.toDouble(),
              (j + 1) * j * gridSize.toDouble(),
            ),
          );
          map[i][j] = enemy;
          add(enemy);
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
