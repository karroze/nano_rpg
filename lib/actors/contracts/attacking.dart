import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/objects/attack.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:flutter/material.dart';

abstract mixin class Attacking {
  // TODO(georgii.savatkov): Remove
  double get attackDistance;

  /// List of attacks available.
  List<Attack> get availableAttacks;

  /// Flag if is attacking.
  bool isAttacking = false;

  /// Flag if attacking is in progress.
  bool isAttackingInProgress = false;

  /// Flag if attacking is possible.
  bool canAttack = true;

  /// Returns an [Attack] to perform.
  @mustCallSuper
  Attack chooseAttack() => availableAttacks.random();

  /// Method to produce an [Damage] object.
  Damage dealDamage({
    Attack? attack,
  }) {
    // Choose attack if no specific attack was provided
    attack ??= chooseAttack();
    final isCritical = Random().nextDouble() > attack.critChance;
    return Damage(
      amount: isCritical ? attack.damageCrit : attack.damage,
      attack: attack,
    );
  }

  /// Method to attack the [target].
  @mustCallSuper
  void attackTarget({
    required Attackable target,
    Attack? attack,
  }) {
    // Check that target is alive
    if (!target.isAlive) return;
    // Toggle attacking
    isAttacking = true;
    // Damage target
    target.receiveDamage(
      damage: dealDamage(
        attack: attack,
      ),
      attacker: this,
    );
  }
}
