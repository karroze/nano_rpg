import 'package:flame_nano_rpg/actors/attackable.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:flutter/material.dart';

abstract mixin class Attacking {
  
  bool isAttacking = false;
  bool isAttackingInProgress = false;
  bool canAttack = true;
  
  /// Method to attack the [target].
  @mustCallSuper
  void attack({
    required Attackable target,
  }) {
    // Check that target is alive
    if(!target.isAlive) return;
    // Toggle attacking
    isAttacking = true;
    // Damage target
    target.receiveDamage(
      damage: dealDamage(),
      attacker: this,
    );
  }

  /// Method to produce an [Damage] object.
  Damage dealDamage();
}
