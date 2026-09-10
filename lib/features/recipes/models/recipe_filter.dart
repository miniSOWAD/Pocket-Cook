import 'recipe.dart';
enum RecipeSort { recommended, quickest, alphabetical }
class RecipeFilter {
  const RecipeFilter({this.query = '', this.categoryId, this.vegetarianOnly = false, this.quickOnly = false, this.sort = RecipeSort.recommended});
  final String query;
  final String? categoryId;
  final bool vegetarianOnly, quickOnly;
  final RecipeSort sort;
  bool matches(Recipe recipe) {
    final words = query.toLowerCase().trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final searchable = '${recipe.title} ${recipe.tags.join(' ')} ${recipe.ingredients.map((i) => i.name).join(' ')}'.toLowerCase();
    return (categoryId == null || categoryId == recipe.categoryId) &&
      (!vegetarianOnly || recipe.vegetarian) && (!quickOnly || recipe.totalMinutes <= 30) &&
      words.every(searchable.contains);
  }
  List<Recipe> apply(Iterable<Recipe> recipes) {
    final result = recipes.where(matches).toList();
    result.sort((a, b) {
      if (sort == RecipeSort.quickest) {
        final time = a.totalMinutes.compareTo(b.totalMinutes);
        if (time != 0) return time;
      }
      if (sort == RecipeSort.recommended && a.featured != b.featured) return a.featured ? -1 : 1;
      return a.title.compareTo(b.title);
    });
    return result;
  }
}
