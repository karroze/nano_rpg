import 'package:flame/components.dart';

mixin Interactable on PositionComponent {
  /// Distance within which object is interactable.
  double get interactionDistance;
}
