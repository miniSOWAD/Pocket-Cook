import '../../../../core/state/async_notifier.dart';
import '../../models/recipe.dart';
import '../../models/recipe_filter.dart';
import 'recipe_catalog_provider.dart';
class RecipeSearchProvider extends AsyncNotifier {
  RecipeSearchProvider(this.catalog, {String? initialCategory}) : categoryId = initialCategory {
    catalog.addListener(notify);
  }
  final RecipeCatalogProvider catalog;
  String query = '';
  String? categoryId;
  bool vegetarianOnly = false, quickOnly = false;
  RecipeSort sort = RecipeSort.recommended;
  int visibleCount = 12;
  List<Recipe> get results => RecipeFilter(query: query, categoryId: categoryId,
      vegetarianOnly: vegetarianOnly, quickOnly: quickOnly, sort: sort).apply(catalog.recipes);
  List<Recipe> get visibleResults => results.take(visibleCount).toList();
  void setQuery(String value) { query = value; _changed(); }
  void setCategory(String? value) { categoryId = value; _changed(); }
  void setVegetarian(bool value) { vegetarianOnly = value; _changed(); }
  void setQuick(bool value) { quickOnly = value; _changed(); }
  void setSort(RecipeSort value) { sort = value; _changed(); }
  void _changed() { visibleCount = 12; notify(); }
  void showMore() { visibleCount += 12; notify(); }
  @override
  void dispose() { catalog.removeListener(notify); super.dispose(); }
}
