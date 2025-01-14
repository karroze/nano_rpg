import 'package:flame_nano_rpg/actors/contracts/interactable.dart';

mixin Interacting {
  /// Handle NPC interactions with other objects.
  void handleInteractions(List<Interactable> targets);

  /// Method to interact with this.
  ///
  /// Returns true if interaction should happen.
  bool interactWith(
    Interactable object, {
    required double distance,
  });
}
