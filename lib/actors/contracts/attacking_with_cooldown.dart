import 'package:flame_nano_rpg/actors/contracts/attacking.dart';

mixin AttackingWithCooldown on Attacking {
  double get damageCooldownTimeframeSeconds;

  bool canAttack = true;

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
