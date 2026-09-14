import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/features/pantry/models/pantry_item.dart';

void main() {
  test('pantry item round trips through json', () {
    final item = PantryItem(id: 'pantry-rice', ingredientId: 'rice', name: 'Rice', quantity: 2,
      unit: 'kg', lowStockThreshold: 0.5, expiryDate: DateTime(2026, 9, 20), note: 'Basmati', updatedAt: 42);
    final restored = PantryItem.fromJson(item.id, item.toJson());
    expect(restored.ingredientId, 'rice');
    expect(restored.quantity, 2);
    expect(restored.expiryDate, DateTime(2026, 9, 20));
    expect(restored.lowStockThreshold, 0.5);
  });

  test('low stock compares in stored unit', () {
    final item = PantryItem(id: 'one', ingredientId: 'egg', name: 'Eggs', quantity: 4,
      unit: 'pcs', lowStockThreshold: 4, updatedAt: 1);
    expect(item.isLowStock, isTrue);
  });
}
