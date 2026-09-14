class AvailableIngredient {
  const AvailableIngredient({
    required this.name,
    this.quantity,
    this.unit = '',
  });

  final String name;
  final double? quantity;
  final String unit;

  String get displayAmount {
    if (quantity == null) return 'amount not specified';
    final value = quantity!;
    final number = (value - value.round()).abs() < 0.000001
        ? value.round().toString()
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return unit.isEmpty ? number : '$number $unit';
  }
}
