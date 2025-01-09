import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/layout.dart';
import 'package:flame_nano_rpg/nano_rpg_game.dart';
import 'package:flame_nano_rpg/overlays/progress_bars/progress_bar.dart';
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
    required super.anchor,
    this.showLabel = true,
    this.showValueText = true,
    this.labelTextStyle,
    this.valueTextStyle,
  }) : super();

  String label;
  int value;
  int maxValue;
  bool showLabel;
  bool showValueText;
  Color progressColor;
  Color bgColor;
  TextStyle? labelTextStyle;
  TextStyle? valueTextStyle;

  double get _progress => (value / maxValue).clamp(0, 1);

  late final ProgressBar _healthProgressBar;
  TextComponent? _labelTextComponent;
  TextComponent? _healthValueTextComponent;

  /// Position for label.
  Vector2 _positionForLabel() => Vector2.zero();

  /// Position for health bar.
  Vector2 _positionForHealthBar() {
    final posX = switch (_labelTextComponent) {
      null => 0.0,
      _ => _labelTextComponent!.size.x + 5,
    };
    return Vector2(
      posX,
      4,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Initialize fonts
    await _initializeFonts();

    // Add label if not specified otherwise
    if (showLabel) {
      _labelTextComponent = TextComponent(
        text: label,
        textRenderer: TextPaint(
          style: labelTextStyle,
        ),
        anchor: Anchor.centerLeft,
        position: _positionForLabel(),
      );
      await add(_labelTextComponent!);
    }

    // Add progress bar
    _healthProgressBar = ProgressBar(
      progress: _progress,
      progressColor: progressColor,
      bgColor: bgColor,
      position: _positionForHealthBar(),
      size: size,
      anchor: Anchor.centerLeft,
    );
    await add(_healthProgressBar);

    // Add value label if not specified otherwise
    if (showValueText) {
      _healthValueTextComponent = TextComponent(
        text: '0/0',
        textRenderer: TextPaint(
          style: valueTextStyle,
        ),
        anchor: Anchor.center,
        position: Vector2.zero(),
      );
      await _healthProgressBar.add(
        AlignComponent(
          child: _healthValueTextComponent,
          alignment: Anchor.center,
          keepChildAnchor: true,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update progress bar text and position if needed
    _healthProgressBar
      ..progress = _progress
      ..position = _positionForHealthBar();
    // Update value text and position if needed
    if (showValueText) {
      _healthValueTextComponent?.text = '$value/$maxValue';
    }
    // Update label text and position if needed
    if (showLabel) {
      _labelTextComponent
        ?..text = label
        ..position = _positionForLabel();
    }
  }

  /// Method to load default fonts if not specified else.
  FutureOr<void> _initializeFonts() {
    // Load default label style if not provided
    labelTextStyle ??= const TextStyle(
      fontSize: 32,
      color: Colors.white,
    );
    // Load default value style if not provided
    valueTextStyle ??= const TextStyle(
      fontSize: 16,
      color: Colors.black,
    );
  }
}
