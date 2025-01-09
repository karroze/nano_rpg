import 'package:flame_nano_rpg/actors/contracts/attackable.dart';

final class Attack {
  const Attack({
    required this.title,
    required this.damage,
    required this.damageCrit,
    required this.critChance,
    required this.range,
  });

  final String title;
  final int damage;
  final int damageCrit;
  final double critChance;
  final double range;
}
