import 'dart:async';

import 'package:flame_nano_rpg/actors/animators/animator_callbacks.dart';

final class NpcAnimatorCallbacks extends AnimatorCallbacks {
  NpcAnimatorCallbacks({
    this.onAttackStarted,
    this.onAttackEnded,
    this.onHurtStarted,
    this.onHurtEnded,
    this.onDieStarted,
    this.onDieEnded,
  });

  FutureOr<void> Function()? onAttackStarted;

  FutureOr<void> Function()? onAttackEnded;

  FutureOr<void> Function()? onHurtStarted;

  FutureOr<void> Function()? onHurtEnded;

  FutureOr<void> Function()? onDieStarted;

  FutureOr<void> Function()? onDieEnded;
}
