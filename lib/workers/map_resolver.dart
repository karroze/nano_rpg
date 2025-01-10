import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class MapResolver extends Component {
  MapResolver({
    required this.mapSize,
    required this.spawner,
    this.onLoadPlayer,
  });

  final MapVector mapSize;
  final MapSpawner spawner;

  FutureOr<PositionComponent> Function()? onLoadPlayer;

  final map = <List<PositionComponent?>>[];

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Initialize map with empty data
    await _initializeMap();
    // Load map items
    await _loadMap();
    // Load player
    await _loadCustomObjects();
  }

  Future<void> _initializeMap() async {
    // Iterate over X
    for (var i = 0; i < mapSize.x - 1; i++) {
      // Add en empty list of maxSizeY size
      map.add(
        List.filled(
          mapSize.y,
          null,
        ),
      );
    }
  }

  FutureOr<void> _loadMap() async {
    // Iterate over X
    for (var i = 0; i < mapSize.x - 1; i++) {
      // Iterate over Y
      for (var j = 0; j < mapSize.y - 1; j++) {
        final mapPosition = MapVector(i, j);
        // Get object to spawn
        final objectToSpawn = await spawner.spawnObjectAtMapPosition(mapPosition);
        // If there is an object to spawn
        if (objectToSpawn != null) {
          await _addObjectToMap(objectToSpawn);
        }
      }
    }
  }

  FutureOr<void> _addObjectToMap(MapSpawnRequest request) async {
    // Add object to the map
    map[request.position.x][request.position.y] = request.object;
    // Add object to container
    await spawner.onSpawnObject(request);
  }

  FutureOr<void> _loadCustomObjects() async {
    // Get custom object requests
    final customObjects = await spawner.spawnCustomObjects(mapSize);
    // Iterate over tem
    for (final objectRequest in customObjects) {
      // Add object to map
      await _addObjectToMap(
        MapSpawnRequest(
          position: objectRequest.position,
          object: objectRequest.object,
        ),
      );
    }
  }
}
