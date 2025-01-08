import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_nano_rpg/actors/contracts/living.dart';

mixin Moving on PositionComponent, Living {
  double get moveSpeed;

  double get moveDistance;

  late final velocity = Vector2.zero();

  Vector2? walkPoint;

  void handleWalkPoint(
    double dt, {
    required Vector2 walkPoint,
    double endDistance = 0,
  }) {
    // Go to point
    final targetDirection = walkPoint - position;

    // If there, remove walk point
    if (targetDirection.length <= endDistance) {
      this.walkPoint = null;
      velocity.setValues(0, 0);
    } else {
      final isVelocityXZero = (targetDirection.x > 0 && targetDirection.x < 1) || (targetDirection.x < 0 && targetDirection.x > -1);
      final isVelocityYZero = (targetDirection.y > 0 && targetDirection.y < 1) || (targetDirection.y < 0 && targetDirection.y > -1);
      final velocityX = isVelocityXZero ? 0.0 : targetDirection.x / targetDirection.x.abs();
      final velocityY = isVelocityYZero ? 0.0 : targetDirection.y / targetDirection.y.abs();

      // print('Velocity: x: $velocityX y: $velocityY');

      velocity.setValues(
        velocityX,
        velocityY,
      );

      // Calculate new position
      final newPosX = position.x + velocity.x * moveSpeed * dt;
      final newPosY = position.y + velocity.y * moveSpeed * dt;

      // Set new position values
      position.setValues(
        newPosX,
        newPosY,
      );

      // Look at target
      lookAtTarget(walkPoint);
    }
  }

  FutureOr<void> setWalkTarget(
    Vector2 target, {
    double endDistance = 0,
  }) async {
    // Do nothing if dead
    if (!isAlive) return;

    // Calculate X offset based on what side target is relative to enemy
    final xOffset = target.x > position.x ? -endDistance : endDistance;
    // Calculate Y offset based on what side target is relative to enemy
    final yOffset = target.y > position.y ? endDistance : -endDistance;

    // Set walk point with an offset
    walkPoint = target + Vector2(xOffset, yOffset);
  }

  void lookAtTarget(
    Vector2 targetPosition,
  ) {
    // Do nothing if dead
    if (!isAlive) return;

    // Calculate new scale
    final newScaleX = switch (targetPosition.x - position.x >= 5) {
      true => 1.0,
      false => -1.0,
    };

    // print('Current scale: ${scale.x}\tNew scale: $newScaleX');

    // Change scale if new scale differs
    if (scale.x != newScaleX) {
      // print('Changing scale');
      scale.x = newScaleX;
    }
  }
}
