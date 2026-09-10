import '../../../core/storage/document_store.dart';
import 'favorites_repository.dart';
class DocumentFavoritesRepository implements FavoritesRepository {
  DocumentFavoritesRepository(this.store);
  final DocumentStore store;
  @override
  Stream<Set<String>> watchIds(String uid) => store.watchCollection('users/$uid/favorites')
      .map((documents) => documents.map((document) => document.id).toSet());
  @override
  Future<void> setFavorite(String uid, String recipeId, bool saved) => store.writeBatch([
    saved ? DocumentWrite.set('users/$uid/favorites/$recipeId', {
      'recipeId': recipeId, 'savedAt': DateTime.now().millisecondsSinceEpoch,
    }) : DocumentWrite.delete('users/$uid/favorites/$recipeId'),
  ]);
}
