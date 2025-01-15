import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:flame_nano_rpg/objects/fraction.dart';
import 'package:meta/meta.dart';

mixin Attackable on Interactable, Living {
  /// Flag if is currently attacked.
  bool isAttacked = false;

  /// Flag if attacking is in progress
  bool isAttackedInProgress = false;

  /// [Fraction] of the NPC.
  Fraction get fraction;

  /// Method to receive a [damage] from an [attacker].
  @mustCallSuper
  void receiveDamage({
    required Damage damage,
    required Attacking attacker,
  }) {
    // Toggle being attacked
    isAttacked = true;
    // Decrease health
    health -= damage.amount;
    // Clamp between 0 and max health
    health = health.clamp(0, maxHealth);
  }
}
