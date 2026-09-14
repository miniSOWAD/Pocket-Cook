import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/features/make_plate/logic/make_plate_matcher.dart';
import 'package:pocket_cook/features/make_plate/models/available_ingredient.dart';
import 'package:pocket_cook/features/recipes/models/ingredient.dart';
import 'package:pocket_cook/features/recipes/models/recipe.dart';
import 'package:pocket_cook/features/recipes/models/recipe_step.dart';

Recipe recipeWith(List<Ingredient> ingredients) => Recipe(
      id: 'test-recipe',
      title: 'Test plate',
      description: 'Test',
      categoryId: 'dinner',
      prepMinutes: 5,
      cookMinutes: 5,
      baseServings: 2,
      ingredients: ingredients,
      steps: const [RecipeStep(title: 'Cook', instruction: 'Cook it.', timerSeconds: 0)],
      imageAsset: 'assets/images/recipes/bowl.png',
    );

void main() {
  const matcher = MakePlateMatcher();

  test('matches recipe when ingredient names are present without amounts', () {
    final recipe = recipeWith(const [
      Ingredient(id: 'chicken', name: 'Chicken', quantity: 300, unit: 'g'),
      Ingredient(id: 'rice', name: 'Rice', quantity: 200, unit: 'g'),
      Ingredient(id: 'salt', name: 'Salt', unit: '', note: 'to taste'),
    ]);

    final result = matcher.match(
      recipes: [recipe],
      available: const [AvailableIngredient(name: 'Chicken'), AvailableIngredient(name: 'Rice')],
    ).single;

    expect(result.canMakeNow, isTrue);
    expect(result.matchPercent, 100);
  });

  test('converts kg to g and reports shortage when amount is insufficient', () {
    final recipe = recipeWith(const [
      Ingredient(id: 'chicken', name: 'Chicken', quantity: 500, unit: 'g'),
      Ingredient(id: 'rice', name: 'Rice', quantity: 200, unit: 'g'),
    ]);

    final result = matcher.match(
      recipes: [recipe],
      available: const [
        AvailableIngredient(name: 'Chicken', quantity: 0.25, unit: 'kg'),
        AvailableIngredient(name: 'Rice', quantity: 250, unit: 'g'),
      ],
    ).single;

    expect(result.canMakeNow, isFalse);
    expect(result.shortIngredients, hasLength(1));
    expect(result.missingIngredients, isEmpty);
  });

  test('ranks full matches above partial matches', () {
    final easy = recipeWith(const [Ingredient(id: 'egg', name: 'Egg', quantity: 2, unit: 'pcs')]);
    final partial = easy.copyWith(
      id: 'partial',
      title: 'Partial',
      ingredients: const [
        Ingredient(id: 'egg', name: 'Egg', quantity: 2, unit: 'pcs'),
        Ingredient(id: 'potato', name: 'Potato', quantity: 2, unit: 'pcs'),
      ],
    );

    final results = matcher.match(
      recipes: [partial, easy],
      available: const [AvailableIngredient(name: 'Egg', quantity: 2, unit: 'pcs')],
    );

    expect(results.first.recipe.id, 'test-recipe');
    expect(results.first.canMakeNow, isTrue);
  });
}
