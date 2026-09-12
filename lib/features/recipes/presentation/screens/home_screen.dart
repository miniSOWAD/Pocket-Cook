import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
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
    final recipes = [...catalog.recipes]
      ..sort((a, b) => a.featured == b.featured
          ? a.title.compareTo(b.title)
          : a.featured
              ? -1
              : 1);

    return FeaturePage(
      pageKey: 'discover',
      eyebrow: name == null ? "Welcome to Liza's Kitchen" : 'Welcome, $name',
      title: 'Something lovely\nis always cooking.',
      subtitle: 'Thoughtful recipes, gentle planning, and a little everyday magic for your table.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchInvitation(onTap: () => Navigator.pushNamed(context, AppRoutes.search)),
          const SizedBox(height: 24),
          ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
          if (catalog.loading)
            const LoadingView()
          else if (recipes.isEmpty)
            const EmptyStateView(
              title: 'A fresh page in your recipe journal',
              message: 'No published recipes yet. In Firebase mode, run the seed script in the setup guide.',
            )
          else ...[
            _FeaturedRecipe(recipe: recipes.first),
            const SizedBox(height: 34),
            const SectionHeading(
              'Choose by mood',
              subtitle: 'A little shortcut to whatever you are craving.',
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in catalog.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ActionChip(
                        avatar: Icon(_categoryIcon(category.id), size: 18),
                        label: Text(category.name),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.search,
                          arguments: category.id,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            SectionHeading(
              'Made for today',
              subtitle: 'Beautiful recipes worth slowing down for.',
              action: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: const Text('See all'),
              ),
            ),
            RecipeGrid(recipes: recipes.take(8).toList()),
            const SizedBox(height: 28),
            const InfoBanner(
              'Adjust servings, save your favorites, plan the week, and send ingredients straight to your grocery list.',
              icon: Icons.favorite_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchInvitation extends StatelessWidget {
  const _SearchInvitation({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.search_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What shall we make?', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Search recipes or ingredients',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.tune_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          final scheme = Theme.of(context).colorScheme;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? const [Color(0xFF6C3545), Color(0xFF4A2A34)]
                    : const [Color(0xFFF7C8D5), Color(0xFFFFE9D2), Color(0xFFFFF7EE)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dustyRose.withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(32),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: recipe),
                child: Padding(
                  padding: EdgeInsets.all(narrow ? 22 : 30),
                  child: narrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FeaturedCopy(recipe: recipe, narrow: true),
                            const SizedBox(height: 22),
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: RecipeImage(recipe: recipe),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _FeaturedCopy(recipe: recipe, narrow: false)),
                            const SizedBox(width: 26),
                            Container(
                              width: 240,
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.dustyRose.withValues(alpha: 0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: RecipeImage(recipe: recipe),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      );
}

class _FeaturedCopy extends StatelessWidget {
  const _FeaturedCopy({required this.recipe, required this.narrow});
  final Recipe recipe;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Liza loves this one'),
        const SizedBox(height: 16),
        Text(
          recipe.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: narrow ? 28 : 36,
                height: 1.08,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '${recipe.totalMinutes} minutes · ${recipe.difficulty} · a cozy little favorite',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary, size: 19),
            ),
            const SizedBox(width: 11),
            Text('Cook this recipe', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
          ],
        ),
      ],
    );
  }
}
