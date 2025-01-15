import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';

mixin Interacting {
  /// Provides interaction between [Interacting] and [Interactable].
  InteractionHandler? provideInteraction(
    Interactable other, {
    required InteractionPayload payload,
  });
}
