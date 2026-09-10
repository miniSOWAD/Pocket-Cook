import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/recipe_grid.dart';
import '../providers/favorites_provider.dart';
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final catalog = context.watch<RecipeCatalogProvider>();
    final signedIn = context.watch<AuthProvider>().user != null;
    final recipes = catalog.recipes.where((recipe) => favorites.contains(recipe.id)).toList();
    final missing = favorites.ids.where((id) => catalog.byId(id) == null).toList();
    return FeaturePage(title: 'Your saved favorites.', subtitle: 'The recipes you will want to come back to.', eyebrow: 'A personal cookbook',
      child: !signedIn ? const SignInPrompt(message: 'Save the recipes you love and find them all here.')
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(favorites.errorMessage, onRetry: favorites.retry), ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
        if (favorites.loading || catalog.loading) const LoadingView()
        else ...[
          if (recipes.isEmpty) const EmptyStateView(icon: Icons.favorite_border_rounded, title: 'Save your first favorite',
            message: 'Tap the heart on a recipe to add it to your personal cookbook.')
          else RecipeGrid(recipes: recipes),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 24), const InfoBanner('Some saved recipes are no longer published. You can remove these references below.'),
            for (final id in missing) ListTile(title: const Text('Unavailable recipe'), subtitle: Text(id),
              trailing: IconButton(tooltip: 'Remove unavailable favorite', icon: const Icon(Icons.delete_outline_rounded),
                onPressed: favorites.busy ? null : () => favorites.toggle(id))),
          ],
        ],
      ]));
  }
}
