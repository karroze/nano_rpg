import 'package:flame_nano_rpg/actors/contracts/attacking.dart';

mixin AttackingWithCooldown on Attacking {
  /// Time for damage cooldown.
  double get damageCooldownTimeframeSeconds;

  // Current value in seconds of cooldown timer
  late double _damageCooldownTimerValue = damageCooldownTimeframeSeconds;

  /// Handles attacking cooldown, decided by passing [dt].
  void handleAttackingCooldown(double dt) {
    // Change timer value
    _damageCooldownTimerValue -= dt;
    // If timer has fired
    if (_damageCooldownTimerValue <= 0) {
      // Reset timer value
      _damageCooldownTimerValue = damageCooldownTimeframeSeconds;
      // Increase stamina by per timer timeframe value
      canAttack = true;
    } else {
      canAttack = false;
    }
  }
}
