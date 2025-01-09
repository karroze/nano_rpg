import 'package:flame_nano_rpg/objects/attack.dart';

class Damage {
  const Damage({
    required this.amount,
    required this.attack,
  });

  final int amount;
  final Attack attack;
}
