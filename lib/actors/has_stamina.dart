abstract mixin class HasStamina {
  int get maxStamina;

  int get staminaPerHit;

  double get staminaRegenTimeframeSeconds;

  int get staminaRegenPerTimeframe;

  late double _staminaRegenTimerValue = staminaRegenTimeframeSeconds;
  late int stamina = maxStamina;

  bool get hasStaminaForAttack => stamina >= staminaPerHit;

  /// Handles stamina regeneration per timeframe, decided by passed [dt].
  void handleStamina(double dt) {
    _staminaRegenTimerValue -= dt;
    // If timer has fired and stamina is less than max
    if (_staminaRegenTimerValue <= 0 && stamina < maxStamina) {
      // Reset timer value
      _staminaRegenTimerValue = staminaRegenTimeframeSeconds;
      // Increase stamina by per timer timeframe value
      stamina += staminaRegenPerTimeframe;
      // Clamp between 0 and maxStamina value
      stamina = stamina.clamp(0, maxStamina);
    }
  }

  void decreaseStamina(int value) {
    stamina -= value;
  }

  void decreaseStaminaPerHit() {
    stamina -= staminaPerHit;
  }
}
