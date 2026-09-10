import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/features/recipes/models/recipe_filter.dart';
import 'package:recipe_app/features/recipes/presentation/providers/recipe_catalog_provider.dart';
import 'package:recipe_app/features/recipes/presentation/providers/recipe_search_provider.dart';
import '../../helpers/fixtures.dart';
import '../../fakes/fake_recipe_repository.dart';
void main() {
  test('matches words across title and ingredient names', () {
    expect(const RecipeFilter(query: 'RICE salt').matches(sampleRecipe()), isTrue);
    expect(const RecipeFilter(query: 'rice mango').matches(sampleRecipe()), isFalse);
  });
  test('combines quick and vegetarian filters', () {
    final recipes = [sampleRecipe(), sampleRecipe(id: 'long', cookMinutes: 40), sampleRecipe(id: 'meat', vegetarian: false)];
    expect(const RecipeFilter(vegetarianOnly: true, quickOnly: true).apply(recipes).map((r) => r.id), ['rice-bowl']);
  });
  test('sorts by preparation and cooking time', () {
    final recipes = [sampleRecipe(id: 'long', cookMinutes: 40), sampleRecipe(id: 'short', cookMinutes: 5)];
    expect(const RecipeFilter(sort: RecipeSort.quickest).apply(recipes).first.id, 'short');
  });
  test('local show-more resets after search changes', () async {
    final catalog = RecipeCatalogProvider(FakeRecipeRepository(List.generate(15, (i) => sampleRecipe(id: 'r-$i', title: 'Recipe $i'))));
    final search = RecipeSearchProvider(catalog);
    await flushStreams();
    expect(search.visibleResults.length, 12);
    search.showMore(); expect(search.visibleResults.length, 15);
    search.setQuery('Recipe'); expect(search.visibleResults.length, 12);
    search.dispose(); catalog.dispose();
  });
}
