import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';
import 'package:flame_nano_rpg/workers/base_map_resolver.dart';
import 'package:flame_nano_rpg/workers/default_map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_resolver.dart';
import 'package:flame_nano_rpg/workers/map_spawn_request.dart';
import 'package:flame_nano_rpg/workers/map_spawner.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class MainWorld extends World with HasGameRef<NanoRpgGame> {
  // Size in pixels of single map cell
  static final _gridCellSize = Vector2.all(96);

  late final MapSpawner mapSpawner;
  late final MapResolver mapResolver;

  late final MapVector _mapSize;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    await _initialize(loadHud: true);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.gameReset) {
      _initialize(loadHud: false);
    }
  }

  FutureOr<void> onSpawnObject(MapSpawnRequest object) {
    add(object.object);
  }

  FutureOr<void> _initialize({
    required bool loadHud,
  }) async {
    // Get map size
    _mapSize = MapVector(
      (game.size.x / _gridCellSize.x).ceil(),
      (game.size.y / _gridCellSize.y).ceil(),
    );

    // Initialize map spawner
    mapSpawner = DefaultMapSpawner(
      gameSize: game.size,
      gridCellSize: _gridCellSize,
      onSpawnObject: onSpawnObject,
      spawnDebugEnemy: false,
    );

    // Initialize map resolver and add it
    mapResolver = DefaultMapResolver(
      mapSize: _mapSize,
      spawner: mapSpawner,
    );
    await add(mapResolver);

    if (loadHud) {
      // Set camera anchor
      game.camera.viewfinder.anchor = Anchor.topLeft;
      // Add HUD to the viewport
      await game.camera.viewport.add(
        Hud(
          position: Vector2(
            game.size.x / 2,
            game.size.y - 15,
          ),
        ),
      );
      await game.camera.viewport.add(
        FpsTextComponent(
          position: Vector2(
            20,
            20,
          ),
        ),
      );
    }

    game.gameReset = false;
  }

  /// Lookup for [Interactable] objects within [distance] at given [position] on the screen.
  List<Interactable> lookupObjectsForPosition(
    Vector2 position, {
    required int distance,
  }) {
    // Get map position for pixel position
    final mapPosition = _getMapPositionFromWorldCoordinates(position);
    // Get distance for objects lookup as a [MapVector]
    final mapDistance = MapVector(
      (distance / _gridCellSize.x).ceil(),
      (distance / _gridCellSize.y).ceil(),
    );
    // Lookup objects
    return mapResolver.lookupObjectsForPosition(
      mapPosition,
      distance: mapDistance,
    );
  }

  /// Method to removed [object] from map.
  void removeObjectFromMap(PositionComponent object) {
    return mapResolver.removeObjectFromMap(object);
  }

  /// Method to update [object] position on the map.
  void updateObjectFromMap(
    PositionComponent object, {
    required Vector2 newPosition,
  }) {
    return mapResolver.updateObjectFromMap(
      object,
      newPosition: _getMapPositionFromWorldCoordinates(newPosition),
    );
  }

  /// Method to get [MapVector] from world [position]
  MapVector _getMapPositionFromWorldCoordinates(Vector2 position) => MapVector(
        ((position.x / _gridCellSize.x) - 1).ceil().clamp(0, _mapSize.x - 1),
        ((position.y / _gridCellSize.y) - 1).ceil().clamp(0, _mapSize.y - 1),
      );
}
