import '../../recipes/models/recipe.dart';

abstract interface class RecipeManagementRepository {
  Stream<List<Recipe>> watchAllRecipes();
  Future<void> saveRecipe(Recipe recipe);
  Future<void> deleteRecipe(String recipeId);
}
