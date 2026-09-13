import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';
import '../core/storage/firestore_document_store.dart';
import '../core/storage/key_value_store.dart';
import '../features/accounts/data/firestore_account_repository.dart';
import '../features/admin/data/firebase_admin_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/recipe_management/data/firestore_recipe_management_repository.dart';
import '../features/recipes/data/firestore_recipe_repository.dart';
import '../features/requests/data/firestore_request_repository.dart';
import '../firebase_options.dart';
import 'dependencies.dart';

Future<AppDependencies> bootstrap() async {
  final local = PreferencesKeyValueStore(await SharedPreferences.getInstance());
  if (!AppConfig.useFirebase && !AppConfig.useEmulators) return AppDependencies.demo(local);

  await Firebase.initializeApp(
    options: AppConfig.useEmulators
        ? const FirebaseOptions(
            apiKey: 'demo-only-key',
            appId: '1:1234567890:web:recipeappdemo',
            messagingSenderId: '1234567890',
            projectId: AppConfig.emulatorProjectId,
            authDomain: 'demo-recipe-app.firebaseapp.com',
          )
        : DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final functions = FirebaseFunctions.instance;

  if (AppConfig.useEmulators) {
    firestore.settings = const Settings(persistenceEnabled: false);
    firestore.useFirestoreEmulator(AppConfig.emulatorHost, 8080);
    await auth.useAuthEmulator(AppConfig.emulatorHost, 9099);
    functions.useFunctionsEmulator(AppConfig.emulatorHost, 5001);
  }

  final documents = FirestoreDocumentStore(firestore);
  return AppDependencies(
    auth: FirebaseAuthRepository(auth),
    recipes: FirestoreRecipeRepository(firestore),
    documents: documents,
    local: local,
    accounts: FirestoreAccountRepository(firestore),
    admin: FirebaseAdminRepository(functions),
    requests: FirestoreRequestRepository(firestore),
    recipeManagement: FirestoreRecipeManagementRepository(firestore),
  );
}
