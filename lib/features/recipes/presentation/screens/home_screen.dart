import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../models/recipe.dart';
import '../providers/recipe_catalog_provider.dart';
import '../widgets/recipe_grid.dart';
import '../widgets/recipe_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RecipeCatalogProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final name = profile?.displayName ?? auth.user?.name;
    final recipes = [...catalog.recipes]..sort((a, b) => a.featured == b.featured ? a.title.compareTo(b.title) : a.featured ? -1 : 1);
    return FeaturePage(pageKey: 'discover', eyebrow: name == null ? 'Your everyday kitchen' : 'Welcome, $name',
      title: 'Good food.\nMade simple.', subtitle: 'A little inspiration for whatever you are craving.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(readOnly: true, onTap: () => Navigator.pushNamed(context, AppRoutes.search),
          decoration: const InputDecoration(hintText: 'Search recipes or ingredients', prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.tune_rounded))),
        const SizedBox(height: 24), ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
        if (catalog.loading) const LoadingView()
        else if (recipes.isEmpty) const EmptyStateView(title: 'A fresh page in your cookbook',
          message: 'No published recipes yet. In Firebase mode, run the seed script in the setup guide.')
        else ...[
          _FeaturedRecipe(recipe: recipes.first), const SizedBox(height: 30),
          const SectionHeading('What sounds good?'),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            for (final category in catalog.categories) Padding(padding: const EdgeInsets.only(right: 10),
              child: ActionChip(avatar: Icon(_categoryIcon(category.id), size: 18), label: Text(category.name),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search, arguments: category.id))),
          ])),
          const SizedBox(height: 30),
          SectionHeading('Worth making today', action: TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
            child: const Text('View all'))),
          RecipeGrid(recipes: recipes.take(8).toList()),
          const SizedBox(height: 24),
          const InfoBanner('Pick a recipe, adjust the servings, and send the ingredients straight to your grocery list.',
            icon: Icons.lightbulb_outline_rounded),
        ],
      ]));
  }
}
IconData _categoryIcon(String id) => switch (id) {
  'breakfast' => Icons.egg_alt_outlined,
  'lunch' => Icons.lunch_dining_rounded,
  'dinner' => Icons.dinner_dining_rounded,
  'dessert' => Icons.cake_outlined,
  'drinks' => Icons.local_cafe_outlined,
  _ => Icons.tapas_outlined,
};
class _FeaturedRecipe extends StatelessWidget {
  const _FeaturedRecipe({required this.recipe});
  final Recipe recipe;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final narrow = constraints.maxWidth < 500;
    return Material(color: AppTheme.forest, borderRadius: BorderRadius.circular(24), clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: recipe),
        child: Padding(padding: EdgeInsets.all(narrow ? 20 : 30), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Eyebrow('Pick of the day', color: Color(0xFFD1E8BA)),
            const SizedBox(height: 13), Text(recipe.title, style: TextStyle(fontSize: narrow ? 23 : 32,
              fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.8, color: Colors.white)),
            const SizedBox(height: 12), Text('${recipe.totalMinutes} minutes. Plenty of flavor.',
              style: const TextStyle(color: Color(0xFFDAE5DA))),
            const SizedBox(height: 19), const Row(mainAxisSize: MainAxisSize.min, children: [
              Text("Let's make it", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(width: 10), Icon(Icons.arrow_forward_rounded, size: 19, color: Colors.white),
            ]),
          ])),
          const SizedBox(width: 15), ClipOval(child: SizedBox.square(dimension: narrow ? 100 : 190,
            child: RecipeImage(recipe: recipe))),
        ]))));
  });
}
