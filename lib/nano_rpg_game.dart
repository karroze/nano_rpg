import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_nano_rpg/gen/assets.gen.dart';
import 'package:flame_nano_rpg/worlds/main_world.dart';

final class NanoRpgGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late final RouterComponent router;

  @override
  bool get debugMode => false;

  bool gameOver = false;
  bool gameReset = false;

  @override
  FutureOr<void> onLoad() async {
    router = RouterComponent(
      initialRoute: 'world',
      routes: {
        'world': WorldRoute(
          MainWorld.new,
          maintainState: false,
        ),
      },
    );

    await _loadAssets();

    await add(router);

    return super.onLoad();
  }

  FutureOr<void> _loadAssets() async {
    images.prefix = '';
    // Load assets
    await images.loadAll(
      [
        Assets.images.explosion.keyName,
        Assets.images.player.warrior1.idle.keyName,
        Assets.images.player.warrior1.walk.keyName,
        Assets.images.player.warrior1.attack1.keyName,
        Assets.images.player.warrior1.attack2.keyName,
        Assets.images.player.warrior1.attack3.keyName,
        Assets.images.player.warrior1.hurt.keyName,
        Assets.images.player.warrior1.dead.keyName,
        Assets.images.player.warrior2.idle.keyName,
        Assets.images.player.warrior2.walk.keyName,
        Assets.images.player.warrior2.attack1.keyName,
        Assets.images.player.warrior2.attack2.keyName,
        Assets.images.player.warrior2.hurt.keyName,
        Assets.images.player.warrior2.dead.keyName,
        Assets.images.enemies.orcBerserk.idle.keyName,
        Assets.images.enemies.orcBerserk.walk.keyName,
        Assets.images.enemies.orcBerserk.attack1.keyName,
        Assets.images.enemies.orcBerserk.dead.keyName,
        Assets.images.enemies.orcBerserk.hurt.keyName,
        Assets.images.enemies.orcShaman.idle.keyName,
        Assets.images.enemies.orcShaman.walk.keyName,
        Assets.images.enemies.orcShaman.attack1.keyName,
        Assets.images.enemies.orcShaman.dead.keyName,
        Assets.images.enemies.orcShaman.hurt.keyName,
        Assets.images.enemies.orcWarrior.idle.keyName,
        Assets.images.enemies.orcWarrior.walk.keyName,
        Assets.images.enemies.orcWarrior.attack1.keyName,
        Assets.images.enemies.orcWarrior.dead.keyName,
        Assets.images.enemies.orcWarrior.hurt.keyName,
        Assets.images.trees.tree.tree1.keyName,
        Assets.images.trees.tree.tree2.keyName,
        Assets.images.trees.tree.tree3.keyName,
        Assets.images.objects.mushrooms.mushroomPurple.keyName,
        Assets.images.objects.mushrooms.mushroomBlueHat.keyName,
        Assets.images.objects.mushrooms.mushroomStringy.keyName,
        Assets.images.objects.mushrooms.mushroomEmerald.keyName,
      ],
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver && !gameReset) {
      // overlays.add(Overlays.gameOver.value);
      // gameReset = true;
    }
  }

  FutureOr<void> reset() {
    // router.pushReplacementNamed('world');
    // gameOver = false;
  }
}
