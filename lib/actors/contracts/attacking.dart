import 'dart:math';

import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:flutter/material.dart';

abstract mixin class Attacking {
  /// Amount of damage to be produced during a normal hit.
  int get damageAmount;

  /// Amount of damage to be produced during a critical hit.
  int get critDamageAmount;

  /// Chance of critical hit to happen.
  double get critChance;

  /// Distance when attack is possible.
  double get attackRange;

  /// Flag if is attacking.
  bool isAttacking = false;

  /// Flag if attacking is in progress.
  bool isAttackingInProgress = false;

  /// Flag if attacking is possible.
  bool canAttack = true;

  /// Method to produce an [Damage] object.
  Damage dealDamage() {
    final isCritical = Random().nextDouble() > critChance;
    return Damage.melee(
      amount: isCritical ? critDamageAmount : damageAmount,
    );
  }

  /// Method to attack the [target].
  @mustCallSuper
  void attack({
    required Attackable target,
  }) {
    // Check that target is alive
    if (!target.isAlive) return;
    // Toggle attacking
    isAttacking = true;
    // Damage target
    target.receiveDamage(
      damage: dealDamage(),
      attacker: this,
    );
  }
}
