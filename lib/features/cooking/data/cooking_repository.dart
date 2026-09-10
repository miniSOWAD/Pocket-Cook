abstract interface class CookingRepository {
  Map<String, dynamic>? read(String userScope, String recipeId);
  Future<void> save(String userScope, String recipeId, Map<String, dynamic> data);
}
