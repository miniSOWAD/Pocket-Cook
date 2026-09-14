import 'package:pocket_cook/features/recipes/data/recipe_repository.dart';
import 'package:pocket_cook/features/recipes/models/recipe.dart';
import 'package:pocket_cook/features/recipes/models/recipe_category.dart';
class FakeRecipeRepository implements RecipeRepository {
  FakeRecipeRepository(this.recipes);
  final List<Recipe> recipes;
  @override
  Stream<List<Recipe>> watchRecipes() => Stream.value(List.of(recipes));
  @override
  Stream<List<RecipeCategory>> watchCategories() => Stream.value(const [RecipeCategory(id: 'lunch', name: 'Lunch')]);
}
