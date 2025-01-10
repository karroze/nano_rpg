import 'package:flame/components.dart';
import 'package:flame_nano_rpg/workers/map_vector.dart';

final class MapSpawnRequest {
  MapSpawnRequest({
    required this.position,
    required this.object,
  });

  final MapVector position;
  final PositionComponent object;
}
