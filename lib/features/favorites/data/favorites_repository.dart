abstract interface class FavoritesRepository {
  Stream<Set<String>> watchIds(String uid);
  Future<void> setFavorite(String uid, String recipeId, bool saved);
}
