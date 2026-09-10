import '../models/ingredient.dart';
import '../models/recipe.dart';
abstract final class ServingCalculator {
  static double? scale(double? quantity, int baseServings, int selectedServings) {
    if (baseServings < 1 || selectedServings < 1 || selectedServings > 12) {
      throw ArgumentError('Servings must be valid, with a selection from 1 to 12.');
    }
    if (quantity != null && (!quantity.isFinite || quantity < 0)) throw ArgumentError('Invalid quantity');
    return quantity == null ? null : quantity * selectedServings / baseServings;
  }
  static List<Ingredient> ingredientsFor(Recipe recipe, int servings) => recipe.ingredients
      .map((item) => item.withQuantity(scale(item.quantity, recipe.baseServings, servings))).toList();
}
