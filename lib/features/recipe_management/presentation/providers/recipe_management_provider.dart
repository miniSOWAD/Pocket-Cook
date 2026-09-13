import 'dart:async';
import '../../../../core/state/async_notifier.dart';
import '../../../recipes/models/recipe.dart';
import '../../data/recipe_management_repository.dart';

class RecipeManagementProvider extends AsyncNotifier {
  RecipeManagementProvider(this.repository) {
    _subscription = repository.watchAllRecipes().listen(
      (value) {
        recipes = value;
        loading = false;
        notify();
      },
      onError: (Object error, StackTrace stack) {
        loading = false;
        reportError(error);
      },
    );
  }

  final RecipeManagementRepository repository;
  late final StreamSubscription<List<Recipe>> _subscription;
  List<Recipe> recipes = const [];
  bool loading = true;

  Future<bool> save(Recipe recipe) => run(() => repository.saveRecipe(recipe));
  Future<bool> delete(String recipeId) => run(() => repository.deleteRecipe(recipeId));

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
