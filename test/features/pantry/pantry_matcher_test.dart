import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/features/pantry/logic/pantry_matcher.dart';
import 'package:recipe_app/features/pantry/models/pantry_item.dart';
import 'package:recipe_app/features/pantry/models/pantry_match_result.dart';
import 'package:recipe_app/features/recipes/models/ingredient.dart';
import 'package:recipe_app/features/recipes/models/recipe.dart';
import 'package:recipe_app/features/recipes/models/recipe_step.dart';

Recipe recipeWith(List<Ingredient> ingredients) => Recipe(id: 'test', title: 'Test meal', description: 'Test',
  categoryId: 'dinner', prepMinutes: 5, cookMinutes: 10, baseServings: 2, ingredients: ingredients,
  steps: const [RecipeStep(title: 'Cook', instruction: 'Cook it.')], imageAsset: 'assets/images/recipes/green-goddess-bowl.png');

PantryItem pantryItem(String ingredientId, double quantity, String unit) => PantryItem(id: 'p-$ingredientId-$unit',
  ingredientId: ingredientId, name: ingredientId, quantity: quantity, unit: unit,
  updatedAt: 1);

void main() {
  test('kg pantry stock satisfies gram recipe requirement', () {
    final recipe = recipeWith(const [Ingredient(id: 'rice', name: 'Rice', quantity: 500, unit: 'g')]);
    final result = PantryMatcher.match(recipe, 2, [pantryItem('rice', 1, 'kg')]);
    expect(result.canMakeNow, isTrue);
    expect(result.matchPercentage, 100);
  });

  test('scaling servings changes readiness', () {
    final recipe = recipeWith(const [Ingredient(id: 'rice', name: 'Rice', quantity: 500, unit: 'g')]);
    final pantry = [pantryItem('rice', 600, 'g')];
    expect(PantryMatcher.match(recipe, 2, pantry).canMakeNow, isTrue);
    expect(PantryMatcher.match(recipe, 4, pantry).canMakeNow, isFalse);
  });

  test('incompatible units do not guess conversions', () {
    final recipe = recipeWith(const [Ingredient(id: 'flour', name: 'Flour', quantity: 2, unit: 'cup')]);
    final result = PantryMatcher.match(recipe, 2, [pantryItem('flour', 500, 'g')]);
    expect(result.status, PantryMatchStatus.almostReady);
    expect(result.missing.single.ingredient.id, 'flour');
  });

  test('multiple matching pantry entries combine', () {
    final recipe = recipeWith(const [Ingredient(id: 'milk', name: 'Milk', quantity: 1000, unit: 'ml')]);
    final result = PantryMatcher.match(recipe, 2, [pantryItem('milk', 0.6, 'l'), pantryItem('milk', 450, 'ml')]);
    expect(result.canMakeNow, isTrue);
  });

  test('non numeric ingredients do not block readiness', () {
    final recipe = recipeWith(const [Ingredient(id: 'salt', name: 'Salt', quantity: null, unit: '')]);
    final result = PantryMatcher.match(recipe, 2, const []);
    expect(result.canMakeNow, isTrue);
  });
}
