import 'package:flame_nano_rpg/objects/damage_type.dart';

class Damage {
  const Damage({
    required this.amount,
    required this.type,
  });

  const Damage.melee({
    required this.amount,
  }) : type = DamageType.melee;

  final int amount;
  final DamageType type;
}
