abstract mixin class Living {
  int get maxHealth;

  late int health = maxHealth;

  bool get isAlive => health > 0;
}
