import 'package:flame/game.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const GameWidget<NanoRpgGame>.controlled(
      gameFactory: NanoRpgGame.new,
      overlayBuilderMap: {},
    ),
  );
}
