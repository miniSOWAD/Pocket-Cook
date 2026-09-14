import '../../recipes/models/recipe.dart';

class PlateRecipeMatch {
  const PlateRecipeMatch({
    required this.recipe,
    required this.matchPercent,
    required this.matchedIngredients,
    required this.requiredIngredients,
    required this.missingIngredients,
    required this.shortIngredients,
  });

  final Recipe recipe;
  final int matchPercent;
  final int matchedIngredients;
  final int requiredIngredients;
  final List<String> missingIngredients;
  final List<String> shortIngredients;

  bool get canMakeNow => missingIngredients.isEmpty && shortIngredients.isEmpty;

  bool get almostReady => !canMakeNow && matchPercent >= 65;

  String get statusLabel {
    if (canMakeNow) return 'Ready to cook';
    if (almostReady) return 'Almost there';
    return '$matchPercent% match';
  }
}
