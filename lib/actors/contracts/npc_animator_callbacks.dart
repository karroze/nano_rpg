import 'dart:async';

final class NpcAnimatorCallbacks {
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
