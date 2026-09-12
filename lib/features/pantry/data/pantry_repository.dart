import '../models/pantry_item.dart';

abstract interface class PantryRepository {
  Stream<List<PantryItem>> watch(String uid);
  Future<void> save(String uid, PantryItem item);
  Future<void> remove(String uid, String itemId);
}
