import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/objects/attack.dart';

mixin AttackingWithStamina on Attacking, Living, HasStamina {
  @override
  void attackTarget({
    required Attackable target,
    Attack? attack,
  }) {
    // Return if not alive
    if (!isAlive) return;
    // Decrease stamina
    decreaseStaminaPerHit();
    // Set possibility to attack to false
    canAttack = false;
    // Super
    super.attackTarget(
      target: target,
      attack: attack,
    );
  }
}
