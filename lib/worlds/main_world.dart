import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_orc_berserk.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_orc_shaman.dart';
import 'package:flame_nano_rpg/actors/enemies/enemy_orc_warrior.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_blue_hat.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_emerald.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_purple.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_stringy.dart';
import 'package:flame_nano_rpg/actors/npc/friendly_npc_regular.dart';
import 'package:flame_nano_rpg/actors/npc/friendly_npc_warrior_component.dart';
import 'package:flame_nano_rpg/actors/objects/tree.dart';
import 'package:flame_nano_rpg/actors/player.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';

final class MainWorld extends World with HasGameRef<NanoRpgGame> {
  final gridSize = 96;

  static const xOffset = 60;
  static const yOffset = 60;

  final map = <List<PositionComponent?>>[];

  late final Player player;

  @override
  FutureOr<void> onLoad() async {
    await _initialize(loadHud: true);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.gameReset) {
      _initialize(loadHud: false);
    }
  }

  FutureOr<void> _initialize({
    required bool loadHud,
  }) async {
    await _initializeMap();
    await _loadMap();
    // await _loadDebugEnemy();
    await _loadPlayer();
    await _loadFriendlyNpc();

    if (loadHud) {
      // final viewport = FixedSizeViewport(
      //   800,
      //   600,
      // )..add(Hud());
      // final cameraComponent = CameraComponent.withFixedResolution(
      //   world: this,
      //   width: 800,
      //   height: 600,
      // )
      //   ..viewfinder.anchor = Anchor.topLeft
      //   ..viewport = viewport;
      //   // ..follow(
      //   //   player,
      //   //   snap: true,
      //   // );
      // game.camera = cameraComponent;
      game.camera
        ..viewfinder.anchor = Anchor.topLeft
        ..viewport.add(Hud());
    }

    game.gameReset = false;
  }

  Future<void> _initializeMap() async {
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
    }
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
          < 200 => Tree(
              position: spawnPosition,
            ),
          < 500 => [
              MushroomBlueHat(
                position: spawnPosition,
              ),
              MushroomEmerald(
                position: spawnPosition,
              ),
              MushroomPurple(
                position: spawnPosition,
              ),
              MushroomStringy(
                position: spawnPosition,
              ),
            ].random(),
          < 1000 => [
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
          await game.add(objectToSpawn);
        }
      }
    }
  }

  FutureOr<void> _loadDebugEnemy() async {
    // Get number of X and Y grid cells
    final mapSizeX = (game.size.x / gridSize).ceil();
    final maxSizeY = (game.size.y / gridSize).ceil();
    final i = (mapSizeX / 2).toInt() + 2;
    final j = (maxSizeY / 2).toInt();
    final xPosition = xOffset + i * gridSize.toDouble();
    final yPosition = yOffset + j * gridSize.toDouble();

    final spawnPosition = Vector2(xPosition, yPosition);
    final enemy = EnemyOrcShaman(
      position: spawnPosition,
    );
    await game.add(enemy);
    map[i][j] = enemy;
  }

  FutureOr<void> _loadPlayer() async {
    player = Player(
      position: game.size / 2,
    );
    await game.add(player);
  }

  FutureOr<void> _loadFriendlyNpc() async {
    await game.add(
      FriendlyWarriorNpcComponent(
        position: game.size / 2 + Vector2(20, 0),
      ),
    );
  }
}
