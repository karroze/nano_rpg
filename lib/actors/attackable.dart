import 'package:flame_nano_rpg/actors/attacking.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:meta/meta.dart';

abstract mixin class Attackable {
  @mustBeOverridden
  int get maxHealth;

  late int health = maxHealth;

  bool isAttacked = false;

  bool get isAlive => health > 0;

  /// Method to receive a [damage] from an [attacker].
  @mustCallSuper
  void receiveDamage({
    required Damage damage,
    required Attacking attacker,
  }) {
    // Toggle being attacked
    isAttacked = true;
    // Receive damage
    // Decrease health
    health -= damage.amount;
  }
}
