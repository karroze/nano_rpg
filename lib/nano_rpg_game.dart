import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_nano_rpg/worlds/main_world.dart';

final class NanoRpgGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  final playerMaxHealth = 100;
  final playerMaxStamina = 100;

  final playerStaminaPerHit = 25;
  final playerStaminaRegenPerTimeframe = 10;

  late final RouterComponent router;

  late int playerHealth = playerMaxHealth;
  late int playerStamina = playerMaxStamina;

  double staminaRegenTime = 1;

  @override
  FutureOr<void> onLoad() async {
    router = RouterComponent(
      initialRoute: 'world',
      routes: {
        'world': WorldRoute(MainWorld.new),
      },
    );

    await _loadAssets();

    add(router);

    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    // Load assets
    await images.loadAll(
      [
        'explosion.png',
        'player/warrior_1/idle.png',
        'player/warrior_1/walk.png',
        'player/warrior_1/attack_1.png',
        'player/warrior_1/attack_2.png',
        'player/warrior_1/attack_3.png',
        'enemies/orc_berserk/idle.png',
        'enemies/orc_berserk/walk.png',
        'enemies/orc_berserk/attack_1.png',
        'enemies/orc_berserk/dead.png',
        'enemies/orc_berserk/hurt.png',
        'trees/tree/tree_1.png',
        'trees/tree/tree_2.png',
        'trees/tree/tree_3.png',
      ],
    );
  }

  @override
  void update(double dt) {
    staminaRegenTime -= dt;
    if (staminaRegenTime <= 0 && playerStamina < playerMaxStamina) {
      staminaRegenTime = 1;
      playerStamina += playerStaminaRegenPerTimeframe;
      playerStamina = playerStamina.clamp(0, playerMaxStamina);
    }
    super.update(dt);
  }
}
