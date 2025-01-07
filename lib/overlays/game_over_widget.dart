import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/overlays.dart';
import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({
    required this.game,
    super.key,
  });

  final NanoRpgGame game;

  static const blackTextColor = Color.fromRGBO(0, 0, 0, 1);
  static const whiteTextColor = Color.fromRGBO(255, 255, 255, 1);

  Future<void> _onPlayAgainPressed() async {
    await game.reset();
    game.overlays.remove(Overlays.gameOver.value);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            spacing: 40,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 32,
                  color: whiteTextColor,
                ),
              ),
              ElevatedButton(
                onPressed: _onPlayAgainPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteTextColor,
                  fixedSize: const Size(200, 50),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 24,
                    color: blackTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
