import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

abstract class MapResolver extends Component {
  MapResolver({
    required this.mapSize,
    required this.spawner,
    required this.onLoadPlayer,
    required this.shouldLoadMap,
  });

  final MapVector mapSize;
  final MapSpawner spawner;

  final bool shouldLoadMap;

  FutureOr<PositionComponent> Function()? onLoadPlayer;

  final map = <List<List<PositionComponent?>>>[];

  /// Lookups [Interactable] objects within [distance] of given [position].
  List<Interactable> lookupObjectsForPosition(
      MapVector position, {
        required MapVector distance,
      });

  /// Provides logic to load custom objects to the map.
  FutureOr<void> loadCustomObjects();

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Initialize map with empty data
    await initializeMap();
    // If map loading enabled, load map items
    if (shouldLoadMap) {
      await loadMap();
    }
    // Load player
    await loadCustomObjects();
  }

  /// Initializes map cells with empty lists of targets.
  Future<void> initializeMap() async {
    // Iterate over X
    for (var i = 0; i < mapSize.x - 1; i++) {
      // Add en empty list of maxSizeY size
      map.add(
        List.filled(
          mapSize.y,
          [],
        ),
      );
    }
  }

  /// Loads map objects from [spawner].
  FutureOr<void> loadMap() async {
    // Iterate over X
    for (var i = 0; i < mapSize.x - 1; i++) {
      // Iterate over Y
      for (var j = 0; j < mapSize.y - 1; j++) {
        final mapPosition = MapVector(i, j);
        // Get object to spawn
        final objectToSpawn = await spawner.spawnObjectAtMapPosition(mapPosition);
        // If there is an object to spawn
        if (objectToSpawn != null) {
          await addObjectToMap(objectToSpawn);
        }
      }
    }
  }

  /// Gets [MapVector] position for given [object].
  MapVector? getMapPositionForObject(PositionComponent object) {
    // Iterate over X
    for (var x = 0; x < mapSize.x - 1; x++) {
      // Iterate over Y
      for (var y = 0; y < mapSize.y - 1; y++) {
        if (map[x][y].contains(object)) {
          return MapVector(x, y);
        }
      }
    }
    return null;
  }

  /// Method to update [object] position on the map.
  void updateObjectFromMap(
      PositionComponent object, {
        required MapVector newPosition,
      }) {
    // Remove object from map
    removeObjectFromMap(object);
    // Set new position for object
    map[newPosition.x][newPosition.y] = List.of(map[newPosition.x][newPosition.y])..add(object);
  }

  /// Method to removed [object] from map.
  void removeObjectFromMap(PositionComponent object) {
    // Get map position for object
    final mapPositionForObject = getMapPositionForObject(object);
    // If this position exists, remove object from this position
    if (mapPositionForObject != null) {
      map[mapPositionForObject.x][mapPositionForObject.y] = map[mapPositionForObject.x][mapPositionForObject.y]
        ..removeWhere(
              (item) => item == object,
        );
    }
  }

  /// Adds [request] to map.
  FutureOr<void> addObjectToMap(MapSpawnRequest request) async {
    // Add object to the map
    map[request.position.x][request.position.y] = List.of(map[request.position.x][request.position.y])..add(request.object);
    // Add object to container
    await spawner.onSpawnObject(request);
  }
}