import '../core/storage/document_store.dart';
import '../core/storage/key_value_store.dart';
import '../core/storage/local_document_store.dart';
import '../features/accounts/data/account_repository.dart';
import '../features/accounts/data/local_account_repository.dart';
import '../features/admin/data/admin_repository.dart';
import '../features/admin/data/demo_admin_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/demo_auth_repository.dart';
import '../features/cooking/data/cooking_repository.dart';
import '../features/cooking/data/local_cooking_repository.dart';
import '../features/favorites/data/document_favorites_repository.dart';
import '../features/favorites/data/favorites_repository.dart';
import '../features/grocery_list/data/document_grocery_repository.dart';
import '../features/grocery_list/data/grocery_repository.dart';
import '../features/meal_planner/data/document_meal_plan_repository.dart';
import '../features/meal_planner/data/meal_plan_repository.dart';
import '../features/pantry/data/document_pantry_repository.dart';
import '../features/pantry/data/pantry_repository.dart';
import '../features/profile/data/document_profile_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/recipe_management/data/local_recipe_management_repository.dart';
import '../features/recipe_management/data/recipe_management_repository.dart';
import '../features/recipes/data/asset_recipe_repository.dart';
import '../features/recipes/data/recipe_repository.dart';
import '../features/requests/data/local_request_repository.dart';
import '../features/requests/data/request_repository.dart';
import '../features/settings/data/local_settings_repository.dart';
import '../features/settings/data/settings_repository.dart';

class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.recipes,
    required this.documents,
    required KeyValueStore local,
    required this.accounts,
    required this.admin,
    required this.requests,
    required this.recipeManagement,
  })  : favorites = DocumentFavoritesRepository(documents),
        groceries = DocumentGroceryRepository(documents),
        mealPlans = DocumentMealPlanRepository(documents),
        profiles = DocumentProfileRepository(documents),
        pantry = DocumentPantryRepository(documents),
        settings = LocalSettingsRepository(local),
        cooking = LocalCookingRepository(local);

  factory AppDependencies.demo(KeyValueStore storage) {
    final documents = LocalDocumentStore(storage);
    return AppDependencies(
      auth: DemoAuthRepository(storage),
      recipes: AssetRecipeRepository(),
      documents: documents,
      local: storage,
      accounts: LocalAccountRepository(documents),
      admin: const DemoAdminRepository(),
      requests: LocalRequestRepository(documents),
      recipeManagement: const LocalRecipeManagementRepository(),
    );
  }

  final AuthRepository auth;
  final RecipeRepository recipes;
  final DocumentStore documents;
  final AccountRepository accounts;
  final AdminRepository admin;
  final RequestRepository requests;
  final RecipeManagementRepository recipeManagement;
  final FavoritesRepository favorites;
  final GroceryRepository groceries;
  final MealPlanRepository mealPlans;
  final PantryRepository pantry;
  final ProfileRepository profiles;
  final SettingsRepository settings;
  final CookingRepository cooking;

  Future<void> dispose() async {
    await auth.dispose();
    if (documents is LocalDocumentStore) await (documents as LocalDocumentStore).dispose();
  }
}
