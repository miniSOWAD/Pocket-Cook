import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/core/storage/key_value_store.dart';
import 'package:pocket_cook/core/storage/local_document_store.dart';
import 'package:pocket_cook/features/auth/models/auth_user.dart';
import 'package:pocket_cook/features/auth/presentation/providers/auth_provider.dart';
import 'package:pocket_cook/features/grocery_list/data/document_grocery_repository.dart';
import 'package:pocket_cook/features/grocery_list/models/grocery_source.dart';
import 'package:pocket_cook/features/grocery_list/presentation/providers/grocery_provider.dart';
import '../../fakes/fake_auth_repository.dart';
import '../../helpers/fixtures.dart';
void main() {
  late LocalDocumentStore store;
  late FakeAuthRepository authRepository;
  late AuthProvider auth;
  late GroceryProvider grocery;
  setUp(() async {
    store = LocalDocumentStore(MemoryKeyValueStore());
    authRepository = FakeAuthRepository(const AuthUser(uid: 'alice', name: 'Alice', email: 'alice@example.test'));
    auth = AuthProvider(authRepository);
    grocery = GroceryProvider(DocumentGroceryRepository(store), auth);
    await flushStreams();
  });
  tearDown(() async { grocery.dispose(); auth.dispose(); await authRepository.dispose(); await store.dispose(); });
  test('re-adding a recipe updates rather than duplicates its contribution', () async {
    expect(await grocery.addRecipe(sampleRecipe(), 2), isTrue); await flushStreams();
    expect(await grocery.addRecipe(sampleRecipe(), 4), isTrue); await flushStreams();
    expect(grocery.sources, hasLength(1));
    expect(grocery.items.firstWhere((item) => item.name == 'Rice').quantity, 400);
  });
  test('removing one contribution preserves the other quantity', () async {
    await grocery.addRecipe(sampleRecipe(), 2); await flushStreams();
    await grocery.saveManual('Rice', 100, 'g'); await flushStreams();
    expect(grocery.items.firstWhere((item) => item.name == 'Rice').quantity, 300);
    await grocery.removeSource('recipe_rice-bowl'); await flushStreams();
    expect(grocery.items.single.quantity, 100);
  });
  test('updating quantities resets affected checkmarks', () async {
    await grocery.addRecipe(sampleRecipe(), 2); await flushStreams();
    await grocery.toggle(grocery.items.firstWhere((item) => item.name == 'Rice')); await flushStreams();
    expect(grocery.purchasedCount, 1);
    await grocery.addRecipe(sampleRecipe(), 3); await flushStreams();
    expect(grocery.purchasedCount, 0);
  });
  test('week synchronization removes stale entries only within that week', () async {
    final firstWeek = DateTime(2026, 9, 7), otherWeek = DateTime(2026, 9, 14);
    await grocery.syncWeek(firstWeek, [GrocerySource.fromRecipe(sampleRecipe(), 2, sourceId: 'plan_2026-09-08_dinner')]);
    await flushStreams();
    await grocery.syncWeek(otherWeek, [GrocerySource.fromRecipe(sampleRecipe(), 2, sourceId: 'plan_2026-09-15_dinner')]);
    await flushStreams();
    await grocery.syncWeek(firstWeek, []); await flushStreams();
    expect(grocery.sources.map((s) => s.id), ['plan_2026-09-15_dinner']);
  });
  test('signing out clears private grocery state immediately', () async {
    await grocery.addRecipe(sampleRecipe(), 2); await flushStreams();
    authRepository.setUser(null);
    expect(grocery.sources, isEmpty); expect(grocery.checkedKeys, isEmpty);
  });
}
