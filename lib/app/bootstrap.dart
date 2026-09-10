import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';
import '../core/storage/firestore_document_store.dart';
import '../core/storage/key_value_store.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/recipes/data/firestore_recipe_repository.dart';
import '../firebase_options.dart';
import 'dependencies.dart';

Future<AppDependencies> bootstrap() async {
  final local = PreferencesKeyValueStore(await SharedPreferences.getInstance());
  if (!AppConfig.useFirebase && !AppConfig.useEmulators) return AppDependencies.demo(local);
  await Firebase.initializeApp(options: AppConfig.useEmulators ? const FirebaseOptions(
    apiKey: 'demo-only-key', appId: '1:1234567890:web:recipeappdemo',
    messagingSenderId: '1234567890', projectId: AppConfig.emulatorProjectId,
    authDomain: 'demo-recipe-app.firebaseapp.com',
  ) : DefaultFirebaseOptions.currentPlatform);
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  if (AppConfig.useEmulators) {
    firestore.settings = const Settings(persistenceEnabled: false);
    firestore.useFirestoreEmulator(AppConfig.emulatorHost, 8080);
    await auth.useAuthEmulator(AppConfig.emulatorHost, 9099);
  }
  return AppDependencies(auth: FirebaseAuthRepository(auth),
    recipes: FirestoreRecipeRepository(firestore), documents: FirestoreDocumentStore(firestore), local: local);
}
