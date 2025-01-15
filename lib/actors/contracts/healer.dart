import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/interacting.dart';
import 'package:flame_nano_rpg/objects/healing.dart';

mixin Healer on Interacting {
  bool heal({
    required Healable target,
  }) {
    // Check that target is alive
    if (!target.isAlive) return false;

    // Check that target needs healing
    if (target.health >= target.maxHealth) return false;

    // Heal target
    target.receiveHealing(
      healing: produceHealing(),
      healer: this,
    );

    return true;
  }

  Healing produceHealing();
}
