import 'package:flame_nano_rpg/actors/npc/base_npc_component.dart';

mixin Interactable {
  /// Handle NPC interactions with other objects.
  void handleInteractions(List<BaseNpcComponent<Object>> targets);

  /// Method to interact with this.
  ///
  /// Returns true if interaction should happen.
  bool interactWith(
    BaseNpcComponent<Object> object, {
    required double distance,
  });
}
