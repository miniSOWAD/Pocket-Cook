import 'package:recipe_app/features/recipes/models/ingredient.dart';
import 'package:recipe_app/features/recipes/models/recipe.dart';
import 'package:recipe_app/features/recipes/models/recipe_step.dart';
Recipe sampleRecipe({String id = 'rice-bowl', String title = 'Rice bowl', int baseServings = 2,
  bool vegetarian = true, int cookMinutes = 15, List<Ingredient>? ingredients}) => Recipe(
    id: id, title: title, description: 'A test recipe', categoryId: 'lunch', prepMinutes: 5,
    cookMinutes: cookMinutes, baseServings: baseServings, vegetarian: vegetarian,
    imageAsset: 'assets/images/recipes/bowl.png',
    ingredients: ingredients ?? const [Ingredient(id: 'rice', name: 'Rice', quantity: 200, unit: 'g'),
      Ingredient(id: 'salt', name: 'Salt', unit: '', note: 'to taste')],
    steps: const [RecipeStep(title: 'Cook', instruction: 'Cook the rice.', timerSeconds: 60),
      RecipeStep(title: 'Serve', instruction: 'Serve in a bowl.')]);
Future<void> flushStreams() => Future<void>.delayed(const Duration(milliseconds: 2));
