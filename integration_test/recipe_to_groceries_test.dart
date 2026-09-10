import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/app/app.dart';
import 'package:recipe_app/app/app_providers.dart';
import 'package:recipe_app/app/dependencies.dart';
import 'package:recipe_app/core/storage/key_value_store.dart';
import 'package:recipe_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:recipe_app/features/grocery_list/presentation/providers/grocery_provider.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('browse, save, change servings, and add recipe ingredients', (tester) async {
    final dependencies = AppDependencies.demo(MemoryKeyValueStore());
    await dependencies.auth.enterDemo();
    await tester.pumpWidget(AppProviders(dependencies: dependencies, child: const SavorApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).first); await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'pasta'); await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('recipe-tomato-basil-pasta'));
    await tester.ensureVisible(card); await tester.tap(card); await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save recipe')); await tester.pumpAndSettle();
    final detailContext = tester.element(find.byTooltip('Remove from favorites'));
    expect(detailContext.read<FavoritesProvider>().contains('tomato-basil-pasta'), isTrue);
    final more = find.byTooltip('More servings'); await tester.ensureVisible(more);
    await tester.tap(more); await tester.pumpAndSettle();
    final groceriesButton = find.text('Add to groceries'); await tester.ensureVisible(groceriesButton);
    await tester.tap(groceriesButton); await tester.pumpAndSettle();
    final grocery = detailContext.read<GroceryProvider>();
    expect(grocery.sources, hasLength(1)); expect(grocery.sources.single.servings, 3);
    expect(grocery.items.firstWhere((item) => item.name == 'Pasta').quantity, 300);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink()); await dependencies.dispose();
  });
}
