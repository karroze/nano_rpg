import 'dart:async';

import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/workers/base_map_resolver.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class DefaultMapResolver extends MapResolver {
  DefaultMapResolver({
    required super.mapSize,
    required super.spawner,
    super.onLoadPlayer,
    super.shouldLoadMap = true,
  });

  @override
  List<Interactable> lookupObjectsForPosition(
    MapVector position, {
    required MapVector distance,
  }) {
    // List of found objects
    final foundObjects = <Interactable>[];

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
          foundObjects.addAll(objectsAtPosition.whereType<Interactable>().toList());
        }
      }
    }
    return foundObjects;
  }

  @override
  FutureOr<void> loadCustomObjects() async {
    // Get custom object requests
    final customObjects = await spawner.spawnCustomObjects(mapSize);
    // Iterate over them
    for (final objectRequest in customObjects) {
      // Add object to map
      await addObjectToMap(
        MapSpawnRequest(
          position: objectRequest.position,
          object: objectRequest.object,
        ),
      );
    }
  }
}
