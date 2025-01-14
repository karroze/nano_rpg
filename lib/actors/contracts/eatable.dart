import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';
import 'package:flame_nano_rpg/actors/contracts/interactable.dart';

mixin Eatable on Interactable, Healer {
  bool eatBy(Healable target) {
    return heal(target: target);
  }
}
