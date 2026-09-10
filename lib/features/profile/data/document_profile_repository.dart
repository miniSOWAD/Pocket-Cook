import '../../../core/storage/document_store.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';
class DocumentProfileRepository implements ProfileRepository {
  DocumentProfileRepository(this.store);
  final DocumentStore store;
  @override
  Stream<UserProfile?> watch(String uid) => store.watchDocument('users/$uid')
      .map((data) => data == null ? null : UserProfile.fromJson(data));
  @override
  Future<void> save(String uid, UserProfile profile) =>
      store.writeBatch([DocumentWrite.set('users/$uid', profile.toJson())]);
}
