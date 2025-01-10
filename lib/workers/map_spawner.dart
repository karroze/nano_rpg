import 'dart:async';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

abstract class MapSpawner {
  MapSpawner({
    required this.onSpawnObject,
  });

  /// Callback to be called when a new object should be added to the game.
  FutureOr<void> Function(MapSpawnRequest object) onSpawnObject;

  /// Provides a nullable [MapSpawnRequest] describing what object to spawn at given [position].
  FutureOr<MapSpawnRequest?> spawnObjectAtMapPosition(MapVector position);

  /// Provides a list of [MapSpawnRequest] to spawn custom objects within given [mapSize].
  FutureOr<List<MapSpawnRequest>> spawnCustomObjects(MapVector mapSize);
}
