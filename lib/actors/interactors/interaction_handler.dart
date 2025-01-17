import 'package:flame_nano_rpg/actors/interactors/interaction_payload.dart';

abstract class InteractionHandler {
  const InteractionHandler({
    required this.payload,
  });

  final InteractionPayload payload;

  bool performInteraction();
}
