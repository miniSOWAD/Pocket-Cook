import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../meal_planner/presentation/providers/meal_plan_provider.dart';
import '../../../pantry/presentation/providers/pantry_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../models/recipe.dart';
import '../../models/recipe_category.dart';
import '../providers/recipe_catalog_provider.dart';
import '../widgets/recipe_grid.dart';
import '../widgets/recipe_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenMakePlate});

  final VoidCallback? onOpenMakePlate;

  String? _displayName(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final account = context.watch<AccountProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    var name = profile?.displayName.trim();
    if (name == null || name.isEmpty) name = account.account?.displayName.trim();
    if (name == null || name.isEmpty) name = auth.user?.name.trim();

    // Smoothly migrate the old generated Admin display name while the Firebase
    // profile is updated with the new bootstrap default.
    if (account.isAdmin &&
        (name == null ||
            name.isEmpty ||
            name.toLowerCase().endsWith('kitchen admin') ||
            name == 'Pocket Cook Admin')) {
      return 'Md Mahruf';
    }
    return name?.isEmpty == true ? null : name;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RecipeCatalogProvider>();
    final auth = context.watch<AuthProvider>();
    final account = context.watch<AccountProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final groceries = context.watch<GroceryProvider>();
    final mealPlans = context.watch<MealPlanProvider>();
    final pantry = context.watch<PantryProvider>();
    final name = _displayName(context);
    final recipes = [...catalog.recipes]
      ..sort((a, b) => a.featured == b.featured
          ? a.title.compareTo(b.title)
          : a.featured
              ? -1
              : 1);
    final narrow = MediaQuery.sizeOf(context).width < 680;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final plannedThisWeek = mealPlans.forWeek(weekStart).length;
    final openGroceries = groceries.items.where((item) => !item.checked).length;
    final quickRecipes = recipes.where((recipe) => recipe.totalMinutes <= 30).length;
    final vegetarianRecipes = recipes.where((recipe) => recipe.vegetarian).length;

    return SingleChildScrollView(
      key: const PageStorageKey('home-dashboard'),
      padding: EdgeInsets.fromLTRB(
        narrow ? 18 : 32,
        narrow ? 20 : 30,
        narrow ? 18 : 32,
        narrow ? 126 : 44,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(
                name: name,
                signedIn: auth.user != null,
                recipeCount: recipes.length,
                roleLabel: account.roleLabel,
              ),
              const SizedBox(height: 22),
              _HomeHero(
                onMakePlate: onOpenMakePlate,
                onBrowse: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              const SizedBox(height: 18),
              _SearchBar(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              const SizedBox(height: 24),
              _KitchenSnapshot(
                signedIn: auth.user != null,
                recipeCount: recipes.length,
                categoryCount: catalog.categories.length,
                quickRecipeCount: quickRecipes,
                vegetarianCount: vegetarianRecipes,
                savedCount: favorites.ids.length,
                pantryCount: pantry.items.length,
                lowStockCount: pantry.lowStock.length,
                plannedCount: plannedThisWeek,
                groceryOpenCount: openGroceries,
              ),
              const SizedBox(height: 28),
              ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
              if (catalog.loading)
                const LoadingView()
              else if (recipes.isEmpty)
                const EmptyStateView(
                  title: 'Your cookbook is ready for recipes',
                  message: 'No published recipes are available right now.',
                )
              else ...[
                SectionHeading(
                  'Today’s recommendation',
                  subtitle: 'A quick pick from the current Pocket Cook collection.',
                  action: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                    child: const Text('Browse all'),
                  ),
                ),
                _FeaturedRecipe(recipe: recipes.first),
                const SizedBox(height: 34),
                const SectionHeading(
                  'Browse by category',
                  subtitle: 'Find the kind of meal that fits your day.',
                ),
                _CategoryStrip(categories: catalog.categories),
                const SizedBox(height: 36),
                SectionHeading(
                  'Recipes to try',
                  subtitle: 'Fresh ideas from Pocket Cook and community cooks.',
                  action: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('See all'),
                  ),
                ),
                RecipeGrid(recipes: recipes.take(8).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.name,
    required this.signedIn,
    required this.recipeCount,
    required this.roleLabel,
  });

  final String? name;
  final bool signedIn;
  final int recipeCount;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                signedIn ? 'WELCOME BACK' : 'WELCOME TO POCKET COOK',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.25,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                signedIn && name != null ? 'Hi, $name' : 'What are we cooking today?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: MediaQuery.sizeOf(context).width < 520 ? 28 : 34,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                signedIn
                    ? 'Your kitchen dashboard is ready.'
                    : 'Discover recipes, use what you have, and waste less.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderInfoPill(
                    icon: Icons.menu_book_outlined,
                    text: '$recipeCount recipes',
                  ),
                  if (signedIn)
                    _HeaderInfoPill(
                      icon: Icons.verified_user_outlined,
                      text: roleLabel,
                    ),
                  const _HeaderInfoPill(
                    icon: Icons.dashboard_customize_outlined,
                    text: 'Smart kitchen tools',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _HeaderInfoPill extends StatelessWidget {
  const _HeaderInfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _KitchenSnapshot extends StatelessWidget {
  const _KitchenSnapshot({
    required this.signedIn,
    required this.recipeCount,
    required this.categoryCount,
    required this.quickRecipeCount,
    required this.vegetarianCount,
    required this.savedCount,
    required this.pantryCount,
    required this.lowStockCount,
    required this.plannedCount,
    required this.groceryOpenCount,
  });

  final bool signedIn;
  final int recipeCount;
  final int categoryCount;
  final int quickRecipeCount;
  final int vegetarianCount;
  final int savedCount;
  final int pantryCount;
  final int lowStockCount;
  final int plannedCount;
  final int groceryOpenCount;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String value, String label, String detail, Color tint})>[
      (
        icon: Icons.menu_book_outlined,
        value: '$recipeCount',
        label: 'Recipe library',
        detail: '$categoryCount categories',
        tint: AppTheme.lightCyan,
      ),
      (
        icon: Icons.timer_outlined,
        value: '$quickRecipeCount',
        label: 'Quick meals',
        detail: '30 min or less',
        tint: AppTheme.lightIndigo,
      ),
      (
        icon: Icons.eco_outlined,
        value: '$vegetarianCount',
        label: 'Vegetarian',
        detail: 'Plant-forward ideas',
        tint: AppTheme.lightestOrange,
      ),
      if (signedIn) ...[
        (
          icon: Icons.favorite_border_rounded,
          value: '$savedCount',
          label: 'Saved recipes',
          detail: 'Your favourites',
          tint: AppTheme.lightIndigo,
        ),
        (
          icon: Icons.kitchen_outlined,
          value: '$pantryCount',
          label: 'Pantry items',
          detail: lowStockCount == 0 ? 'Stock looks good' : '$lowStockCount running low',
          tint: AppTheme.lightCyan,
        ),
        (
          icon: Icons.calendar_month_outlined,
          value: '$plannedCount',
          label: 'Meals planned',
          detail: 'This week',
          tint: AppTheme.lightestOrange,
        ),
        (
          icon: Icons.shopping_bag_outlined,
          value: '$groceryOpenCount',
          label: 'To buy',
          detail: 'Unchecked groceries',
          tint: AppTheme.lightCyan,
        ),
      ] else
        (
          icon: Icons.inventory_2_outlined,
          value: '$categoryCount',
          label: 'Meal groups',
          detail: 'Browse by category',
          tint: AppTheme.lightCyan,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          'Kitchen snapshot',
          subtitle: 'Useful numbers at a glance before you decide what to cook.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                    ? 3
                    : 2;
            final ratio = columns == 2 ? 1.70 : 1.92;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: ratio,
              ),
              itemBuilder: (context, index) => _SnapshotCard(item: items[index]),
            );
          },
        ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.item});

  final ({IconData icon, String value, String label, String detail, Color tint}) item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: item.tint.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.10 : 0.64,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.82)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 19, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 1,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onMakePlate, required this.onBrowse});

  final VoidCallback? onMakePlate;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: const Text(
                  'SMART KITCHEN ASSISTANT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Turn what you have\ninto something good.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: narrow ? 30 : 40,
                      height: 1.04,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'Tell Pocket Cook what is in your kitchen. We’ll compare it with real recipe ingredients and show what you can make now.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onMakePlate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.lightOrange,
                      foregroundColor: const Color(0xFF3D2A11),
                    ),
                    icon: const Icon(Icons.ramen_dining_rounded),
                    label: const Text('Make ur plate'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onBrowse,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Browse recipes'),
                  ),
                ],
              ),
            ],
          );

          final art = Container(
            width: narrow ? double.infinity : 270,
            height: narrow ? 150 : 230,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: narrow ? 100 : 142,
                  height: narrow ? 100 : 142,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.ramen_dining_rounded,
                    size: narrow ? 56 : 78,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: narrow ? 34 : 28,
                  top: narrow ? 18 : 28,
                  child: _IngredientDot(icon: Icons.egg_alt_outlined),
                ),
                Positioned(
                  left: narrow ? 28 : 22,
                  bottom: narrow ? 18 : 28,
                  child: _IngredientDot(icon: Icons.eco_outlined),
                ),
                Positioned(
                  right: narrow ? 82 : 48,
                  bottom: narrow ? 14 : 20,
                  child: _IngredientDot(icon: Icons.local_fire_department_outlined),
                ),
              ],
            ),
          );

          return Container(
            padding: EdgeInsets.all(narrow ? 22 : 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF087F91), Color(0xFF0CA6B8), Color(0xFF18C8D7)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepCyan.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copy, const SizedBox(height: 24), art],
                  )
                : Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 26),
                      art,
                    ],
                  ),
          );
        },
      );
}

class _IngredientDot extends StatelessWidget {
  const _IngredientDot({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.lightOrange,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF4A2F14), size: 21),
      );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepCyan.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.search_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Search recipes, ingredients or categories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories});

  final List<RecipeCategory> categories;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Material(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.search,
                    arguments: category.id,
                  ),
                  child: Container(
                    width: 126,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_categoryIcon(category.id), color: scheme.primary, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(category.name, style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(String id) => switch (id) {
      'breakfast' => Icons.egg_alt_outlined,
      'lunch' => Icons.lunch_dining_outlined,
      'dinner' => Icons.dinner_dining_outlined,
      'dessert' => Icons.cake_outlined,
      'drinks' => Icons.local_cafe_outlined,
      'snacks' => Icons.tapas_outlined,
      _ => Icons.restaurant_outlined,
    };

class _FeaturedRecipe extends StatelessWidget {
  const _FeaturedRecipe({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 680;
          final scheme = Theme.of(context).colorScheme;
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: narrow ? 16 / 9 : 1.15,
              child: RecipeImage(recipe: recipe),
            ),
          );
          final copy = Padding(
            padding: EdgeInsets.all(narrow ? 18 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EDITOR’S PICK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: 9),
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(icon: Icons.schedule_rounded, text: '${recipe.totalMinutes} min'),
                    _MetaPill(icon: Icons.signal_cellular_alt_rounded, text: recipe.difficulty),
                    _MetaPill(icon: Icons.person_outline_rounded, text: '${recipe.baseServings} servings'),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.recipe,
                    arguments: recipe,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('View recipe'),
                ),
              ],
            ),
          );

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: narrow
                ? Column(children: [image, copy])
                : Row(
                    children: [
                      Expanded(flex: 5, child: image),
                      Expanded(flex: 6, child: copy),
                    ],
                  ),
          );
        },
      );
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
