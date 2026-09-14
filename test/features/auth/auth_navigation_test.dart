import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/app/app.dart';
import 'package:pocket_cook/app/app_providers.dart';
import 'package:pocket_cook/app/dependencies.dart';
import 'package:pocket_cook/core/storage/key_value_store.dart';
import 'package:pocket_cook/core/storage/local_document_store.dart';
import 'package:pocket_cook/features/accounts/data/local_account_repository.dart';
import 'package:pocket_cook/features/admin/data/demo_admin_repository.dart';
import 'package:pocket_cook/features/recipe_management/data/local_recipe_management_repository.dart';
import 'package:pocket_cook/features/requests/data/local_request_repository.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_recipe_repository.dart';

void main() {
  Future<AppDependencies> pumpCloudLikeApp(WidgetTester tester) async {
    final storage = MemoryKeyValueStore();
    final documents = LocalDocumentStore(storage);
    final dependencies = AppDependencies(
      auth: FakeAuthRepository(),
      recipes: FakeRecipeRepository(const []),
      documents: documents,
      local: storage,
      accounts: LocalAccountRepository(documents),
      admin: const DemoAdminRepository(),
      requests: LocalRequestRepository(documents),
      recipeManagement: const LocalRecipeManagementRepository(),
    );
    await tester.pumpWidget(
      AppProviders(
        dependencies: dependencies,
        child: const PocketCookApp(),
      ),
    );
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('sign-up link opens the registration page without a route type crash', (tester) async {
    final dependencies = await pumpCloudLikeApp(tester);

    await tester.tap(find.text('Sign in').first);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back to Pocket Cook.'), findsOneWidget);

    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your Pocket Cook account.'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await dependencies.dispose();
  });

  testWidgets('forgot password route opens from sign-in', (tester) async {
    final dependencies = await pumpCloudLikeApp(tester);

    await tester.tap(find.text('Sign in').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Back to your kitchen.'), findsOneWidget);
    expect(find.text('Send reset email'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await dependencies.dispose();
  });
}
