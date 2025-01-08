import 'package:flame_nano_rpg/actors/contracts/attackable.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_cooldown.dart';
import 'package:flame_nano_rpg/actors/contracts/attacking_with_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/base_npc.dart';
import 'package:flame_nano_rpg/actors/contracts/has_stamina.dart';
import 'package:flame_nano_rpg/actors/contracts/moving.dart';

abstract class EnemyNpc<State> extends BaseNpc<State> with Moving, Attackable, Attacking, AttackingWithCooldown, HasStamina, AttackingWithStamina {
  EnemyNpc({
    required super.position,
    required super.size,
    required super.anchor,
  });
}
