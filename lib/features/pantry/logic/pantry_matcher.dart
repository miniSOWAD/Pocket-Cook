import '../../recipes/logic/serving_calculator.dart';
import '../../recipes/models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/pantry_match_result.dart';
import 'pantry_units.dart';

abstract final class PantryMatcher {
  static PantryMatchResult match(Recipe recipe, int servings, Iterable<PantryItem> pantry) {
    final scaled = ServingCalculator.ingredientsFor(recipe, servings);
    final rows = <PantryIngredientMatch>[];

    for (final ingredient in scaled) {
      final requiredQuantity = ingredient.quantity;
      // Non-numeric ingredients such as "salt to taste" are treated as optional
      // for readiness because a precise stock comparison is impossible.
      if (requiredQuantity == null) {
        rows.add(PantryIngredientMatch(ingredient: ingredient, available: true,
          requiredQuantity: null, availableQuantity: null, unit: ingredient.unit));
        continue;
      }

      var availableCanonical = 0.0;
      String? canonicalUnit;
      for (final item in pantry.where((item) => item.ingredientId.toLowerCase() == ingredient.id.toLowerCase())) {
        final normalized = PantryUnits.canonical(item.unit, item.quantity);
        final needed = PantryUnits.canonical(ingredient.unit, requiredQuantity);
        if (normalized.unit != needed.unit) continue;
        canonicalUnit ??= needed.unit;
        availableCanonical += normalized.quantity;
      }
      final needed = PantryUnits.canonical(ingredient.unit, requiredQuantity);
      final available = availableCanonical + 1e-9 >= needed.quantity;
      rows.add(PantryIngredientMatch(ingredient: ingredient, available: available,
        requiredQuantity: needed.quantity, availableQuantity: availableCanonical,
        unit: canonicalUnit ?? needed.unit));
    }

    final requiredRows = rows.where((row) => row.requiredQuantity != null).toList();
    final matched = requiredRows.where((row) => row.available).length;
    final percentage = requiredRows.isEmpty ? 100.0 : matched * 100 / requiredRows.length;
    final missing = requiredRows.length - matched;
    final status = missing == 0
        ? PantryMatchStatus.canMakeNow
        : (missing <= 2 || percentage >= 80)
            ? PantryMatchStatus.almostReady
            : percentage >= 50
                ? PantryMatchStatus.missingSome
                : PantryMatchStatus.notReady;

    return PantryMatchResult(recipe: recipe, servings: servings,
      matches: List.unmodifiable(rows), matchPercentage: percentage, status: status);
  }
}
