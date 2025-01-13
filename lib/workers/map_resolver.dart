import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class MapResolver extends Component {
  MapResolver({
    required this.mapSize,
    required this.spawner,
    this.onLoadPlayer,
    this.loadMap = true,
  });

  final MapVector mapSize;
  final MapSpawner spawner;

  final bool loadMap;

  FutureOr<PositionComponent> Function()? onLoadPlayer;

  final map = <List<List<PositionComponent?>>>[];

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Initialize map with empty data
    await _initializeMap();
    // If map loading enabled, load map items
    if (loadMap) {
      await _loadMap();
    }
    // Load player
    await _loadCustomObjects();
  }

  /// Method to removed [object] from map.
  void removeObjectFromMap(PositionComponent object) {
    // Get map position for object
    final mapPositionForObject = _getMapPositionForObject(object);
    // If this position exists, remove object from this position
    if (mapPositionForObject != null) {
      map[mapPositionForObject.x][mapPositionForObject.y] = map[mapPositionForObject.x][mapPositionForObject.y]
        ..removeWhere(
          (item) => item == object,
        );
    }
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

  MapVector? _getMapPositionForObject(PositionComponent object) {
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

  List<BaseNpcComponent<Object>> lookupObjectsForPosition(
    MapVector position, {
    required MapVector distance,
  }) {
    // List of found objects
    final foundObjects = <BaseNpcComponent<Object>>[];

    // Clamp lookup X position start and end
    final requestedStartPositionX = position.x - distance.x;
    final requestedEndPositionX = position.x + distance.x;
    final startPosX = requestedStartPositionX >= 0 ? requestedStartPositionX : requestedStartPositionX.clamp(0, position.x);
    final endPosX = requestedEndPositionX < mapSize.x ? requestedEndPositionX : requestedEndPositionX.clamp(position.x, mapSize.x - 1);

    // Clamp lookup Y position start and end
    final requestedStartPositionY = position.y - distance.y;
    final requestedEndPositionY = position.y + distance.y;
    final startPosY = requestedStartPositionY >= 0 ? requestedStartPositionY : requestedStartPositionY.clamp(0, position.y);
    final endPosY = requestedEndPositionY < mapSize.y ? requestedEndPositionY : requestedEndPositionY.clamp(position.y, mapSize.y - 1);

    // Iterate over X
    for (var x = startPosX; x < endPosX; x++) {
      // Iterate over Y
      for (var y = startPosY; y < endPosY; y++) {
        // Get object at X,Y
        final objectsAtPosition = List.of(map[x][y]);
        // If there is an object
        if (objectsAtPosition.isNotEmpty) {
          foundObjects.addAll(objectsAtPosition.whereType<BaseNpcComponent<Object>>().toList());
        }
      }
    }
    return foundObjects;
  }

  Future<void> _initializeMap() async {
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
    map[request.position.x][request.position.y] = List.of(map[request.position.x][request.position.y])..add(request.object);
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
