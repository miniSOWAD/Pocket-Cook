import 'dart:convert';
import '../../../core/storage/key_value_store.dart';
import 'cooking_repository.dart';
class LocalCookingRepository implements CookingRepository {
  LocalCookingRepository(this.storage);
  final KeyValueStore storage;
  String _key(String scope, String recipeId) => 'savor.cooking.$scope.$recipeId';
  @override
  Map<String, dynamic>? read(String userScope, String recipeId) {
    final value = storage.read(_key(userScope, recipeId));
    return value == null ? null : Map<String, dynamic>.from(jsonDecode(value) as Map);
  }
  @override
  Future<void> save(String userScope, String recipeId, Map<String, dynamic> data) =>
    storage.write(_key(userScope, recipeId), jsonEncode(data));
}
