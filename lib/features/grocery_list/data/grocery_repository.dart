import '../models/grocery_source.dart';
abstract interface class GroceryRepository {
  Stream<List<GrocerySource>> watchSources(String uid);
  Stream<Set<String>> watchCheckedKeys(String uid);
  Future<void> saveSources(String uid, List<GrocerySource> sources,
      {Set<String> resetKeys = const {}, Set<String> removeSourceIds = const {}});
  Future<void> setChecked(String uid, String key, bool checked);
  Future<void> clear(String uid, Iterable<String> sourceIds, Iterable<String> checkedKeys);
}
