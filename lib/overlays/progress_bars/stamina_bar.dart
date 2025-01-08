import 'package:flame/components.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/labeled_progress_bar.dart';
import 'package:flutter/material.dart';

final class StaminaBar extends LabeledProgressBar {
  StaminaBar({
    required super.value,
    required super.maxValue,
    required super.position,
  }) : super(
          label: 'Stamina:',
          progressColor: Colors.green,
          bgColor: Colors.white,
          size: Vector2(100, 20),
        );
}
