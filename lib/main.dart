import 'package:flame/game.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/game_over_widget.dart';
import 'package:flame_nano_rpg/overlays/overlays.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget<NanoRpgGame>.controlled(
      gameFactory: NanoRpgGame.new,
      overlayBuilderMap: {
        Overlays.gameOver.value: (_, game) => GameOverWidget(
              game: game,
            ),
      },
    ),
  );
}
