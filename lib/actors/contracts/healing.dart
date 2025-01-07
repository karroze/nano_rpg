import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/objects/healing.dart';
import 'package:meta/meta.dart';

abstract mixin class Healer {
  void heal({
    required Healable target,
  }) {
    // Check that target is alive
    if (!target.isAlive) return;

    // Heal target
    target.receiveHealing(
      healing: produceHealing(),
      healer: this,
    );
  }

  Healing produceHealing();
}
