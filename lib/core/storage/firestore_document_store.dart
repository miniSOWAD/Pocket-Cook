import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_store.dart';

class FirestoreDocumentStore implements DocumentStore {
  FirestoreDocumentStore(this.firestore);
  final FirebaseFirestore firestore;
  @override
  Stream<List<StoredDocument>> watchCollection(String path) => firestore
      .collection(path).snapshots().map((snapshot) => snapshot.docs
      .map((doc) => StoredDocument(doc.id, doc.data())).toList());
  @override
  Stream<Json?> watchDocument(String path) =>
      firestore.doc(path).snapshots().map((snapshot) => snapshot.data());
  @override
  Future<void> writeBatch(List<DocumentWrite> writes) async {
    if (writes.length > 450) throw ArgumentError('Split large batches before saving.');
    final batch = firestore.batch();
    for (final write in writes) {
      final ref = firestore.doc(write.path);
      if (write.data == null) { batch.delete(ref); }
      else { batch.set(ref, write.data!); }
    }
    await batch.commit();
  }
}
