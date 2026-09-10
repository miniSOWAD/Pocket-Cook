import 'dart:async';
import '../../../../core/state/async_notifier.dart';
import '../../data/recipe_repository.dart';
import '../../models/recipe.dart';
import '../../models/recipe_category.dart';
class RecipeCatalogProvider extends AsyncNotifier {
  RecipeCatalogProvider(this.repository) { load(); }
  final RecipeRepository repository;
  StreamSubscription<List<Recipe>>? _recipesSub;
  StreamSubscription<List<RecipeCategory>>? _categoriesSub;
  List<Recipe> recipes = [];
  List<RecipeCategory> categories = [];
  bool loading = true;
  int _generation = 0;
  void load() {
    final generation = ++_generation;
    unawaited(_recipesSub?.cancel());
    unawaited(_categoriesSub?.cancel());
    loading = true;
    errorMessage = null;
    _recipesSub = repository.watchRecipes().listen((value) {
      if (isDisposed || generation != _generation) return;
      recipes = List.unmodifiable([...value]..sort((a, b) => a.title.compareTo(b.title)));
      loading = false;
      errorMessage = null;
      notify();
    }, onError: (Object error, StackTrace stack) {
      if (generation != _generation || isDisposed) return;
      loading = false;
      reportError(error);
    });
    _categoriesSub = repository.watchCategories().listen((value) {
      if (generation != _generation || isDisposed) return;
      categories = List.unmodifiable(value);
      notify();
    }, onError: (Object error, StackTrace stack) {
      if (generation == _generation && !isDisposed) reportError(error);
    });
    notify();
  }
  Recipe? byId(String id) {
    for (final recipe in recipes) { if (recipe.id == id) return recipe; }
    return null;
  }
  String categoryName(String id) {
    for (final category in categories) { if (category.id == id) return category.name; }
    return id.isEmpty ? 'Recipe' : '${id[0].toUpperCase()}${id.substring(1)}';
  }
  @override
  void dispose() { unawaited(_recipesSub?.cancel()); unawaited(_categoriesSub?.cancel()); super.dispose(); }
}
