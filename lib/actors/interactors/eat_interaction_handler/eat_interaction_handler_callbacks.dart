import 'dart:async';

import 'package:flame_nano_rpg/actors/contracts/eatable.dart';

final class EatInteractionHandlerCallbacks {
  EatInteractionHandlerCallbacks({
    this.onEatableConsumed,
  });

  FutureOr<void> Function(Eatable eatable)? onEatableConsumed;
}
