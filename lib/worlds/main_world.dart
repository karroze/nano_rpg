import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/hud.dart';
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
    final mapSize = MapVector(
      (game.size.x / _gridCellSize.x).ceil(),
      (game.size.y / _gridCellSize.y).ceil(),
    );

    // Initialize map spawner
    mapSpawner = DefaultMapSpawner(
      gameSize: game.size,
      gridCellSize: _gridCellSize,
      onSpawnObject: onSpawnObject,
    );

    // Initialize map resolver and add it
    mapResolver = MapResolver(
      mapSize: mapSize,
      spawner: mapSpawner,
    );
    await add(mapResolver);

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

      // Set camera anchor
      game.camera.viewfinder.anchor = Anchor.topLeft;
      // Add HUD to the viewport
      await game.camera.viewport.add(Hud());
    }

    game.gameReset = false;
  }
}
