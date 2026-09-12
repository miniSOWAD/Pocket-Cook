import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/favorites/presentation/providers/favorites_provider.dart';
import '../features/grocery_list/presentation/providers/grocery_provider.dart';
import '../features/meal_planner/presentation/providers/meal_plan_provider.dart';
import '../features/pantry/presentation/providers/pantry_provider.dart';
import '../features/profile/presentation/providers/profile_provider.dart';
import '../features/recipes/presentation/providers/recipe_catalog_provider.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'dependencies.dart';
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.dependencies, required this.child});
  final AppDependencies dependencies;
  final Widget child;
  @override
  Widget build(BuildContext context) => MultiProvider(providers: [
    Provider<AppDependencies>.value(value: dependencies),
    ChangeNotifierProvider(create: (_) => AuthProvider(dependencies.auth), lazy: false),
    ChangeNotifierProvider(create: (_) => SettingsProvider(dependencies.settings)),
    ChangeNotifierProvider(create: (_) => RecipeCatalogProvider(dependencies.recipes), lazy: false),
    ChangeNotifierProvider(create: (context) => FavoritesProvider(dependencies.favorites, context.read<AuthProvider>()), lazy: false),
    ChangeNotifierProvider(create: (context) => ProfileProvider(dependencies.profiles, context.read<AuthProvider>()), lazy: false),
    ChangeNotifierProvider(create: (context) => GroceryProvider(dependencies.groceries, context.read<AuthProvider>()), lazy: false),
    ChangeNotifierProvider(create: (context) => MealPlanProvider(dependencies.mealPlans, context.read<AuthProvider>()), lazy: false),
    ChangeNotifierProvider(create: (context) => PantryProvider(dependencies.pantry, context.read<AuthProvider>()), lazy: false),
  ], child: child);
}
