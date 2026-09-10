import '../../recipes/models/ingredient.dart';
import '../../recipes/models/recipe.dart';
import '../../recipes/logic/serving_calculator.dart';

/// An ingredient contribution, not a second editable recipe record.
class GrocerySource {
  const GrocerySource({required this.id, required this.title, this.recipeId,
    required this.servings, required this.ingredients, required this.updatedAt});
  final String id, title;
  final String? recipeId;
  final int servings, updatedAt;
  final List<Ingredient> ingredients;
  bool get isManual => recipeId == null;
  factory GrocerySource.fromRecipe(Recipe recipe, int servings, {String? sourceId, String? title}) => GrocerySource(
    id: sourceId ?? 'recipe_${recipe.id}', title: title ?? recipe.title,
    recipeId: recipe.id, servings: servings,
    ingredients: ServingCalculator.ingredientsFor(recipe, servings),
    updatedAt: DateTime.now().millisecondsSinceEpoch,
  );
  factory GrocerySource.fromJson(String id, Map<String, dynamic> json) {
    final result = GrocerySource(
    id: id, title: json['title'] as String, recipeId: json['recipeId'] as String?,
    servings: (json['servings'] as num).toInt(), updatedAt: (json['updatedAt'] as num).toInt(),
    ingredients: (json['ingredients'] as List).map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
    );
    if (result.title.trim().isEmpty || result.servings < 1 || result.servings > 12 ||
        result.ingredients.isEmpty || result.ingredients.length > 80 || result.updatedAt < 0) {
      throw const FormatException('Invalid grocery contribution.');
    }
    return result;
  }
  Map<String, dynamic> toJson() => {'title': title, 'recipeId': recipeId, 'servings': servings,
    'updatedAt': updatedAt, 'ingredients': ingredients.map((item) => item.toJson()).toList()};
}
