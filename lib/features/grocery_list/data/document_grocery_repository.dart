import '../../../core/storage/document_store.dart';
import '../models/grocery_source.dart';
import 'grocery_repository.dart';
class DocumentGroceryRepository implements GroceryRepository {
  DocumentGroceryRepository(this.store);
  final DocumentStore store;
  @override
  Stream<List<GrocerySource>> watchSources(String uid) => store.watchCollection('users/$uid/grocerySources')
    .map((documents) => documents.map((doc) => GrocerySource.fromJson(doc.id, doc.data)).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  @override
  Stream<Set<String>> watchCheckedKeys(String uid) => store.watchCollection('users/$uid/groceryChecks')
    .map((documents) => documents.where((doc) => doc.data['checked'] == true).map((doc) => doc.id).toSet());
  @override
  Future<void> saveSources(String uid, List<GrocerySource> sources,
      {Set<String> resetKeys = const {}, Set<String> removeSourceIds = const {}}) => store.writeBatch([
    for (final id in removeSourceIds) DocumentWrite.delete('users/$uid/grocerySources/$id'),
    for (final source in sources) DocumentWrite.set('users/$uid/grocerySources/${source.id}', source.toJson()),
    for (final key in resetKeys) DocumentWrite.delete('users/$uid/groceryChecks/$key'),
  ]);
  @override
  Future<void> setChecked(String uid, String key, bool checked) => store.writeBatch([
    checked ? DocumentWrite.set('users/$uid/groceryChecks/$key', {'checked': true})
      : DocumentWrite.delete('users/$uid/groceryChecks/$key'),
  ]);
  @override
  Future<void> clear(String uid, Iterable<String> sourceIds, Iterable<String> checkedKeys) => store.writeBatch([
    for (final id in sourceIds) DocumentWrite.delete('users/$uid/grocerySources/$id'),
    for (final key in checkedKeys) DocumentWrite.delete('users/$uid/groceryChecks/$key'),
  ]);
}
