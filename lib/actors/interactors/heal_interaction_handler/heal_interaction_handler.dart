import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';
import 'package:flame_nano_rpg/actors/interactors/interaction_handler.dart';

final class HealInteractionHandler extends InteractionHandler {
  const HealInteractionHandler({
    required this.healer,
    required this.target,
    required super.payload,
  });

  final Healer healer;
  final Healable target;

  @override
  bool performInteraction() {
    target.receiveHealing(
      healing: healer.produceHealing(),
      healer: healer,
    );
    return true;
  }
}
