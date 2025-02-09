import 'package:flame/components.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/labeled_progress_bar.dart';
import 'package:flutter/material.dart';

final class HealthBar extends LabeledProgressBar {
  HealthBar({
    required super.value,
    required super.maxValue,
    required super.position,
    required super.anchor,
    Vector2? size,
    super.showLabel,
    super.showValueText,
    super.labelTextStyle,
    super.valueTextStyle,
  }) : super(
          label: 'Health:',
          progressColor: Colors.red,
          bgColor: Colors.white,
          size: size ?? Vector2(100, 20),
        );
}
