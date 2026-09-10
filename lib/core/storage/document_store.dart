typedef Json = Map<String, dynamic>;

class StoredDocument {
  const StoredDocument(this.id, this.data);
  final String id;
  final Json data;
}

class DocumentWrite {
  const DocumentWrite.set(this.path, Json value) : data = value;
  const DocumentWrite.delete(this.path) : data = null;
  final String path;
  final Json? data;
}

abstract interface class DocumentStore {
  Stream<List<StoredDocument>> watchCollection(String path);
  Stream<Json?> watchDocument(String path);
  Future<void> writeBatch(List<DocumentWrite> writes);
}
