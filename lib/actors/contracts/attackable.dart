import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/objects/damage.dart';
import 'package:meta/meta.dart';

mixin Attackable on Living {
  /// Flag if is currently attacked.
  bool isAttacked = false;

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
