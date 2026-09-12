import '../../../core/storage/document_store.dart';
import '../models/pantry_item.dart';
import 'pantry_repository.dart';

class DocumentPantryRepository implements PantryRepository {
  DocumentPantryRepository(this.store);
  final DocumentStore store;

  @override
  Stream<List<PantryItem>> watch(String uid) => store.watchCollection('users/$uid/pantryItems').map((docs) {
        final items = docs.map((doc) => PantryItem.fromJson(doc.id, doc.data)).toList();
        items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return items;
      });

  @override
  Future<void> save(String uid, PantryItem item) => store.writeBatch([
        DocumentWrite.set('users/$uid/pantryItems/${item.id}', item.toJson()),
      ]);

  @override
  Future<void> remove(String uid, String itemId) => store.writeBatch([
        DocumentWrite.delete('users/$uid/pantryItems/$itemId'),
      ]);
}
