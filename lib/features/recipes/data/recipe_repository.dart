import '../models/recipe.dart';
import '../models/recipe_category.dart';
abstract interface class RecipeRepository {
  Stream<List<Recipe>> watchRecipes();
  Stream<List<RecipeCategory>> watchCategories();
}
