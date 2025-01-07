import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bar.dart';
import 'package:flutter/material.dart';

abstract class LabeledProgressBar extends PositionComponent with HasGameRef<NanoRpgGame> {
  LabeledProgressBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.progressColor,
    required this.bgColor,
    required super.position,
    required super.size,
    this.showValueText = true,
  }) : super(
          anchor: Anchor.topLeft,
        );

  String label;
  int value;
  int maxValue;
  bool showValueText;
  Color progressColor;
  Color bgColor;

  double get progress => (value / maxValue).clamp(0, 1);

  late final TextComponent _labelTextComponent;
  late final TextComponent _healthValueTextComponent;
  late final ProgressBar _healthProgressBar;

  @override
  FutureOr<void> onLoad() {
    _labelTextComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: position,
    );
    game.add(_labelTextComponent);

    _healthProgressBar = ProgressBar(
      progress: progress,
      progressColor: progressColor,
      bgColor: bgColor,
      position: position + Vector2(_labelTextComponent.size.x + 5, 4),
      size: size,
      anchor: Anchor.centerLeft,
    );

    game.add(_healthProgressBar);

    if (showValueText) {
      _healthValueTextComponent = TextComponent(
        text: '0/0',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        anchor: Anchor.centerLeft,
        position: position + Vector2(_labelTextComponent.size.x + _healthProgressBar.size.x / 4 + 2, 4),
      );
      game.add(_healthValueTextComponent);
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _healthProgressBar.progress = progress;
    if (showValueText) {
      _healthValueTextComponent.text = '$value/$maxValue';
    }
    super.update(dt);
  }
}
