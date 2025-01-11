import 'dart:async';
import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_blue_hat.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_emerald.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_purple.dart';
import 'package:flame_nano_rpg/actors/food/mushrooms/mushroom_stringy.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_berserk/enemy_orc_berserk_component.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_shaman/enemy_orc_shaman_component.dart';
import 'package:flame_nano_rpg/actors/npc/enemies/orc_warrior/enemy_orc_warrior_component.dart';
import 'package:flame_nano_rpg/actors/npc/friendly/friendly_warrior/friendly_warrior_component.dart';
import 'package:flame_nano_rpg/actors/objects/tree.dart';
import 'package:flame_nano_rpg/actors/player/player.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class DefaultMapSpawner extends MapSpawner {
  DefaultMapSpawner({
    required this.gameSize,
    required this.gridCellSize,
    required super.onSpawnObject,
    this.spawnPlayer = true,
    this.spawnDebugEnemy = true,
    this.spawnFriendlyWarrior = true,
  });

  final Vector2 gameSize;
  final Vector2 gridCellSize;

  final bool spawnPlayer;
  final bool spawnDebugEnemy;
  final bool spawnFriendlyWarrior;

  static const xOffset = 60;
  static const yOffset = 60;

  @override
  FutureOr<List<MapSpawnRequest>> spawnCustomObjects(MapVector mapSize) {
    // List of spawn requests
    final spawnRequests = <MapSpawnRequest>[];

    // Get center position of map size
    final mapSizeCenterVector = MapVector(
      (mapSize.x / 2).ceil(),
      (mapSize.y / 2).ceil(),
    );

    // Create player
    if (spawnPlayer) {
      spawnRequests.add(
        MapSpawnRequest(
          position: mapSizeCenterVector,
          object: Player(
            position: gameSize / 2,
          ),
        ),
      );
    }

    if (spawnFriendlyWarrior) {
      spawnRequests.add(
        MapSpawnRequest(
          position: MapVector(
            mapSizeCenterVector.x + 1,
            mapSizeCenterVector.y,
          ),
          object: FriendlyWarriorComponent(
            position: gameSize / 2 + Vector2(gridCellSize.x, 0),
          ),
        ),
      );
    }

    if (spawnDebugEnemy) {
      spawnRequests.add(
        MapSpawnRequest(
          position: MapVector(
            mapSizeCenterVector.x + 2,
            mapSizeCenterVector.y,
          ),
          object: EnemyOrcShamanComponent(
            position: gameSize / 2 + Vector2(gridCellSize.x * 2, 0),
          ),
        ),
      );
    }
    return spawnRequests;
  }

  @override
  FutureOr<MapSpawnRequest?> spawnObjectAtMapPosition(MapVector position) async {
    final xPosition = xOffset + position.x * gridCellSize.x;
    final yPosition = yOffset + position.y * gridCellSize.y;

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
          EnemyOrcBerserkComponent(
            position: spawnPosition,
          ),
          EnemyOrcShamanComponent(
            position: spawnPosition,
          ),
          EnemyOrcWarriorComponent(
            position: spawnPosition,
          ),
        ].random(),
      _ => null,
    };

    // If there is no object to spawn, return null request
    if (objectToSpawn == null) return null;

    // Return object spawn request
    return MapSpawnRequest(
      position: position,
      object: objectToSpawn,
    );
  }
}
