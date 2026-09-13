import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/app/app.dart';
import 'package:recipe_app/app/app_providers.dart';
import 'package:recipe_app/app/dependencies.dart';
import 'package:recipe_app/core/storage/key_value_store.dart';
import 'package:recipe_app/core/storage/local_document_store.dart';

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
    );
    await tester.pumpWidget(
      AppProviders(
        dependencies: dependencies,
        child: const LizasKitchenApp(),
      ),
    );
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('sign-up link opens the registration page without a route type crash', (tester) async {
    final dependencies = await pumpCloudLikeApp(tester);

    await tester.tap(find.text('Sign in').first);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, lovely.'), findsOneWidget);

    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('A lovely new beginning.'), findsOneWidget);
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
