import '../../../../core/state/async_notifier.dart';
import '../../logic/serving_calculator.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
class RecipeDetailProvider extends AsyncNotifier {
  RecipeDetailProvider(this.recipe) : servings = recipe.baseServings;
  final Recipe recipe;
  int servings;
  List<Ingredient> get ingredients => ServingCalculator.ingredientsFor(recipe, servings);
  void setServings(int value) {
    if (value < 1 || value > 12) return;
    servings = value;
    notify();
  }
}
