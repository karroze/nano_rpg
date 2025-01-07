import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';
import 'package:flame_nano_rpg/objects/healing.dart';
import 'package:meta/meta.dart';

mixin Healable on Living {
  /// Receive a [healing] from [healer].
  @mustCallSuper
  void receiveHealing({
    required Healing healing,
    required Healer healer,
  }) {
    // Add healing amount to the health
    health += healing.amount.clamp(0, maxHealth);
    // Clamp between 0 and max health
    health = health.clamp(0, maxHealth);
  }
}
