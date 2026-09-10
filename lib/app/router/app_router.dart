import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/common.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/cooking/presentation/providers/cooking_provider.dart';
import '../../features/cooking/presentation/screens/cooking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/recipes/models/recipe.dart';
import '../../features/recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../features/recipes/presentation/providers/recipe_detail_provider.dart';
import '../../features/recipes/presentation/providers/recipe_search_provider.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipe_search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../dependencies.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(settings: settings, builder: (context) {
      switch (settings.name) {
        case AppRoutes.home: return const MainShell();
        case AppRoutes.login: return const LoginScreen();
        case AppRoutes.register: return const RegisterScreen();
        case AppRoutes.forgotPassword: return const ForgotPasswordScreen();
        case AppRoutes.search:
          return ChangeNotifierProvider(create: (_) => RecipeSearchProvider(context.read<RecipeCatalogProvider>(),
            initialCategory: settings.arguments is String ? settings.arguments as String : null), child: const RecipeSearchScreen());
        case AppRoutes.recipe:
          final recipe = settings.arguments;
          if (recipe is Recipe) return ChangeNotifierProvider(create: (_) => RecipeDetailProvider(recipe), child: const RecipeDetailScreen());
          break;
        case AppRoutes.cooking:
          final arguments = settings.arguments;
          if (arguments is CookingArguments && arguments.recipe.steps.isNotEmpty) {
            return ChangeNotifierProvider(create: (_) => CookingProvider(context.read<AppDependencies>().cooking,
              arguments.recipe, context.read<AuthProvider>().user?.uid ?? 'guest', arguments.servings), child: const CookingScreen());
          }
          break;
        case AppRoutes.profile:
          return Scaffold(appBar: AppBar(title: const Text('Your profile')), body: const SafeArea(child: ProfileScreen()));
        case AppRoutes.editProfile: return const EditProfileScreen();
        case AppRoutes.settings: return const SettingsScreen();
      }
      return Scaffold(appBar: AppBar(title: const Text('Savor')), body: const EmptyStateView(
        title: 'That page is not available', message: 'Go back and choose a recipe from the cookbook.'));
    });
  }
}
