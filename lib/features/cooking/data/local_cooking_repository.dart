import 'dart:async';
import 'dart:convert';
import '../../../core/storage/key_value_store.dart';
import 'cooking_repository.dart';
class LocalCookingRepository implements CookingRepository {
  LocalCookingRepository(this.storage);
  final KeyValueStore storage;
  String _key(String scope, String recipeId) => 'pocket_cook.cooking.$scope.$recipeId';
  String _legacyKey(String scope, String recipeId) => 'pocket_cook_legacy.cooking.$scope.$recipeId';
  @override
  Map<String, dynamic>? read(String userScope, String recipeId) {
    final currentKey = _key(userScope, recipeId);
    final value = storage.read(currentKey) ?? storage.read(_legacyKey(userScope, recipeId));
    if (value != null && storage.read(currentKey) == null) {
      unawaited(storage.write(currentKey, value));
    }
    return value == null ? null : Map<String, dynamic>.from(jsonDecode(value) as Map);
  }
  @override
  Future<void> save(String userScope, String recipeId, Map<String, dynamic> data) =>
    storage.write(_key(userScope, recipeId), jsonEncode(data));
}
