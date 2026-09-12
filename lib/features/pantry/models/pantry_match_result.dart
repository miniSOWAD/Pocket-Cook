import '../../recipes/models/ingredient.dart';
import '../../recipes/models/recipe.dart';

enum PantryMatchStatus { canMakeNow, almostReady, missingSome, notReady }

class PantryIngredientMatch {
  const PantryIngredientMatch({required this.ingredient, required this.available,
    required this.requiredQuantity, required this.availableQuantity, required this.unit});
  final Ingredient ingredient;
  final bool available;
  final double? requiredQuantity;
  final double? availableQuantity;
  final String unit;
}

class PantryMatchResult {
  const PantryMatchResult({required this.recipe, required this.servings, required this.matches,
    required this.matchPercentage, required this.status});
  final Recipe recipe;
  final int servings;
  final List<PantryIngredientMatch> matches;
  final double matchPercentage;
  final PantryMatchStatus status;

  List<PantryIngredientMatch> get missing => matches.where((item) => !item.available).toList();
  int get matchedCount => matches.length - missing.length;
  bool get canMakeNow => status == PantryMatchStatus.canMakeNow;
}
