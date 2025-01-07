import 'package:flame_nano_rpg/actors/contracts/healable.dart';
import 'package:flame_nano_rpg/actors/contracts/healer.dart';

mixin Eatable on Healer {
  bool eatBy(Healable target) {
    return heal(target: target);
  }
}
