abstract final class PantryUnits {
  static const supported = {'pcs', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup'};

  static ({String unit, double quantity}) canonical(String unit, double quantity) {
    final normalized = unit.trim().toLowerCase();
    return switch (normalized) {
      'kg' => (unit: 'g', quantity: quantity * 1000),
      'l' => (unit: 'ml', quantity: quantity * 1000),
      _ => (unit: normalized, quantity: quantity),
    };
  }

  static double? convert(double quantity, String from, String to) {
    final source = canonical(from, quantity);
    final target = canonical(to, 1);
    if (source.unit != target.unit) return null;
    final divisor = target.quantity;
    return divisor == 0 ? null : source.quantity / divisor;
  }
}
