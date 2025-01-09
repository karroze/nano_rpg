import 'dart:ui';

import 'package:flame/components.dart';

final class ProgressBar extends PositionComponent {
  ProgressBar({
    required this.progress,
    required this.progressColor,
    required this.bgColor,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });

  double progress;
  final Color progressColor;
  final Color bgColor;

  late final progressPaint = Paint()..color = progressColor;
  late final bgPaint = Paint()..color = bgColor;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas
      ..drawRect(
        size.toRect(),
        bgPaint,
      )
      ..drawRect(
        Vector2(size.x * progress, size.y).toRect(),
        progressPaint,
      );
  }
}
