import 'dart:async';
import 'dart:convert';
import 'document_store.dart';
import 'key_value_store.dart';

/// Demo-only storage. This is not encryption or production authentication.
class LocalDocumentStore implements DocumentStore {
  LocalDocumentStore(this._storage) {
    final saved = _storage.read(_storageKey);
    if (saved != null) {
      final parsed = Map<String, dynamic>.from(jsonDecode(saved) as Map);
      _documents = parsed.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)));
    }
  }
  static const _storageKey = 'savor.documents.v1';
  final KeyValueStore _storage;
  Map<String, Json> _documents = {};
  final _changes = StreamController<void>.broadcast(sync: true);
  Future<void> _tail = Future<void>.value();

  Json _copy(Json data) => Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);

  Stream<T> _watch<T>(T Function() read) => Stream<T>.multi((controller) {
    final sub = _changes.stream.listen((_) => controller.add(read()),
        onError: controller.addError);
    controller.add(read());
    controller.onCancel = sub.cancel;
  }, isBroadcast: true);

  @override
  Stream<List<StoredDocument>> watchCollection(String path) => _watch(() {
    final prefix = '$path/';
    return _documents.entries
        .where((entry) => entry.key.startsWith(prefix) &&
            !entry.key.substring(prefix.length).contains('/'))
        .map((entry) => StoredDocument(entry.key.substring(prefix.length), _copy(entry.value)))
        .toList();
  });

  @override
  Stream<Json?> watchDocument(String path) => _watch(() {
    final data = _documents[path];
    return data == null ? null : _copy(data);
  });

  @override
  Future<void> writeBatch(List<DocumentWrite> writes) {
    final result = _tail.then((_) async {
      final next = Map<String, Json>.from(_documents);
      for (final write in writes) {
        if (write.data == null) { next.remove(write.path); }
        else { next[write.path] = _copy(write.data!); }
      }
      await _storage.write(_storageKey, jsonEncode(next));
      _documents = next;
      _changes.add(null);
    });
    // Keep the queue usable after a failed write, while exposing that failure.
    _tail = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<void> dispose() => _changes.close();
}
