import '../../../core/errors/app_exception.dart';
import '../../recipes/models/recipe.dart';
import 'recipe_management_repository.dart';

class LocalRecipeManagementRepository implements RecipeManagementRepository {
  const LocalRecipeManagementRepository();

  @override
  Stream<List<Recipe>> watchAllRecipes() => const Stream.empty();

  @override
  Future<void> saveRecipe(Recipe recipe) async => throw const AppException('Recipe management requires Firebase mode.');

  @override
  Future<void> deleteRecipe(String recipeId) async => throw const AppException('Recipe management requires Firebase mode.');
}
