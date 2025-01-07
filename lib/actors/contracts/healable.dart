import 'package:flame_nano_rpg/actors/contracts/living.dart';
import 'package:flame_nano_rpg/actors/contracts/healing.dart';
import 'package:flame_nano_rpg/objects/healing.dart';
import 'package:meta/meta.dart';

mixin Healable on Living {
  
  /// Receive a [healing] from [healer].
  @mustCallSuper
  void receiveHealing({
    required Healing healing,
    required Healer healer,
  }) {
    health += healing.amount;
  }
}
