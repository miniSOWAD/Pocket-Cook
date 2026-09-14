import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/features/recipes/models/ingredient.dart';
import 'package:pocket_cook/features/grocery_list/models/grocery_source.dart';
import 'package:pocket_cook/features/grocery_list/logic/ingredient_merger.dart';
GrocerySource source(String id, List<Ingredient> ingredients) => GrocerySource(id: id, title: id,
  servings: 2, ingredients: ingredients, updatedAt: 1);
void main() {
  test('merges the same ingredient and unit', () {
    final items = IngredientMerger.merge([
      source('a', [const Ingredient(id: 'rice', name: 'Rice', quantity: 200, unit: 'g')]),
      source('b', [const Ingredient(id: 'rice', name: 'Rice', quantity: 150, unit: 'g')]),
    ], {});
    expect(items, hasLength(1)); expect(items.single.quantity, 350); expect(items.single.sourceIds, {'a', 'b'});
  });
  test('converts kilograms to grams', () {
    final items = IngredientMerger.merge([
      source('a', [const Ingredient(id: 'rice', name: 'Rice', quantity: 1, unit: 'kg')]),
      source('b', [const Ingredient(id: 'rice', name: 'Rice', quantity: 250, unit: 'g')]),
    ], {});
    expect(items.single.quantity, 1250); expect(items.single.unit, 'g');
  });
  test('converts liters to milliliters', () {
    final items = IngredientMerger.merge([
      source('a', [const Ingredient(id: 'milk', name: 'Milk', quantity: 1, unit: 'l')]),
      source('b', [const Ingredient(id: 'milk', name: 'Milk', quantity: 250, unit: 'ml')]),
    ], {});
    expect(items.single.quantity, 1250); expect(items.single.unit, 'ml');
  });
  test('does not guess cup-to-gram conversions', () {
    final items = IngredientMerger.merge([source('a', [
      const Ingredient(id: 'rice', name: 'Rice', quantity: 1, unit: 'cup'),
      const Ingredient(id: 'rice', name: 'Rice', quantity: 200, unit: 'g'),
    ])], {});
    expect(items, hasLength(2));
  });
  test('nonnumeric ingredients remain separate from numeric amounts', () {
    final items = IngredientMerger.merge([source('a', [
      const Ingredient(id: 'salt', name: 'Salt', unit: ''),
      const Ingredient(id: 'salt', name: 'Salt', quantity: 1, unit: 'tsp'),
    ])], {});
    expect(items, hasLength(2)); expect(items.where((i) => i.quantity == null), hasLength(1));
  });
  test('checkmarks use stable keys', () {
    const ingredient = Ingredient(id: 'rice', name: 'Rice', quantity: 1, unit: 'kg');
    final key = IngredientMerger.keyFor(ingredient);
    final items = IngredientMerger.merge([source('a', [ingredient])], {key});
    expect(items.single.checked, isTrue); expect(key.contains('/'), isFalse);
  });
}
