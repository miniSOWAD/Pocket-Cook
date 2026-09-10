import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/core/storage/key_value_store.dart';
import 'package:recipe_app/core/storage/local_document_store.dart';
import 'package:recipe_app/core/storage/document_store.dart';
void main() {
  test('batches persist and can be read after reopening', () async {
    final storage = MemoryKeyValueStore(); final store = LocalDocumentStore(storage);
    await store.writeBatch([const DocumentWrite.set('users/alice/items/a', {'value': 1}),
      const DocumentWrite.set('users/alice/items/b', {'value': 2})]);
    final reopened = LocalDocumentStore(storage);
    expect(await reopened.watchCollection('users/alice/items').first, hasLength(2));
    await store.dispose(); await reopened.dispose();
  });
  test('collection reads include only immediate children', () async {
    final store = LocalDocumentStore(MemoryKeyValueStore());
    await store.writeBatch([const DocumentWrite.set('users/alice/items/a', {'value': 1}),
      const DocumentWrite.set('users/alice/items/a/nested/b', {'value': 2}),
      const DocumentWrite.set('users/bob/items/a', {'value': 3})]);
    final result = await store.watchCollection('users/alice/items').first;
    expect(result, hasLength(1)); expect(result.single.data['value'], 1); await store.dispose();
  });
  test('concurrent writes are serialized without dropping documents', () async {
    final store = LocalDocumentStore(MemoryKeyValueStore());
    await Future.wait(List.generate(10, (i) => store.writeBatch([DocumentWrite.set('items/$i', {'value': i})])));
    expect(await store.watchCollection('items').first, hasLength(10)); await store.dispose();
  });
  test('returned maps do not mutate the stored data', () async {
    final store = LocalDocumentStore(MemoryKeyValueStore());
    await store.writeBatch([const DocumentWrite.set('items/a', {'value': 1})]);
    final data = await store.watchDocument('items/a').first; data!['value'] = 99;
    expect((await store.watchDocument('items/a').first)!['value'], 1); await store.dispose();
  });
}
