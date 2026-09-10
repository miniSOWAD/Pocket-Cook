import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../models/recipe.dart';
import 'recipe_card.dart';
class RecipeGrid extends StatelessWidget {
  const RecipeGrid({super.key, required this.recipes});
  final List<Recipe> recipes;
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = scale > 1.35 && width < 650 ? 1 : width < 300 ? 1 : width < 650 ? 2 : width < 1000 ? 3 : 4;
      return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: recipes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns,
          crossAxisSpacing: 16, mainAxisSpacing: 18, mainAxisExtent: 292.0 + (scale - 1).clamp(0.0, 2.0).toDouble() * 100),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(key: ValueKey('recipe-${recipe.id}'), recipe: recipe,
            isFavorite: favorites.contains(recipe.id),
            onFavoritePressed: favorites.busy ? null : () => toggleFavorite(context, recipe.id),
            onTap: () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: recipe));
        });
    });
  }
}
