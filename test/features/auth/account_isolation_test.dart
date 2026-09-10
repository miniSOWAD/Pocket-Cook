import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/core/storage/key_value_store.dart';
import 'package:recipe_app/core/storage/local_document_store.dart';
import 'package:recipe_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:recipe_app/features/favorites/data/document_favorites_repository.dart';
import 'package:recipe_app/features/favorites/presentation/providers/favorites_provider.dart';
import '../../fakes/fake_auth_repository.dart';
import '../../helpers/fixtures.dart';
void main() {
  test('account switching never shows the previous user favorites', () async {
    final store = LocalDocumentStore(MemoryKeyValueStore());
    final repository = DocumentFavoritesRepository(store);
    await repository.setFavorite('alice', 'alice-recipe', true);
    await repository.setFavorite('bob', 'bob-recipe', true);
    final authRepository = FakeAuthRepository();
    final auth = AuthProvider(authRepository);
    final favorites = FavoritesProvider(repository, auth);
    authRepository.setUser('alice'); await flushStreams(); expect(favorites.ids, {'alice-recipe'});
    authRepository.setUser('bob'); expect(favorites.ids, isEmpty);
    await flushStreams(); expect(favorites.ids, {'bob-recipe'});
    authRepository.setUser(null); expect(favorites.ids, isEmpty);
    favorites.dispose(); auth.dispose(); await authRepository.dispose(); await store.dispose();
  });
  test('rapid account changes resolve to the latest account', () async {
    final store = LocalDocumentStore(MemoryKeyValueStore());
    final repository = DocumentFavoritesRepository(store);
    await repository.setFavorite('alice', 'alice-recipe', true);
    await repository.setFavorite('bob', 'bob-recipe', true);
    final authRepository = FakeAuthRepository(); final auth = AuthProvider(authRepository);
    final favorites = FavoritesProvider(repository, auth);
    authRepository.setUser('alice'); authRepository.setUser('bob'); authRepository.setUser('alice');
    await flushStreams(); expect(favorites.ids, {'alice-recipe'});
    favorites.dispose(); auth.dispose(); await authRepository.dispose(); await store.dispose();
  });
}
