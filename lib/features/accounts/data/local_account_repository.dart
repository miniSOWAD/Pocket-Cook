import '../../../core/storage/document_store.dart';
import '../../auth/models/auth_user.dart';
import '../models/app_account.dart';
import 'account_repository.dart';

class LocalAccountRepository implements AccountRepository {
  LocalAccountRepository(this.store);
  final DocumentStore store;

  @override
  Stream<AppAccount?> watchAccount(String uid) => store
      .watchDocument('accounts/$uid')
      .map((data) => data == null ? null : AppAccount.fromJson(uid, data));

  @override
  Stream<List<AppAccount>> watchCooks() => store.watchCollection('accounts').map((docs) {
        final result = docs
            .map((doc) => AppAccount.fromJson(doc.id, doc.data))
            .where((user) => user.isActive && (user.isCook || user.isAdmin))
            .toList();
        result.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        return result;
      });

  @override
  Future<void> createVisitor(AuthUser user) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await store.writeBatch([
      DocumentWrite.set('accounts/${user.uid}', {
        'displayName': user.name.trim().isEmpty ? 'Home cook' : user.name.trim(),
        'photoUrl': user.photoUrl.trim(),
        'role': 'visitor',
        'status': 'active',
        'createdAt': now,
        'updatedAt': now,
      }),
    ]);
  }

  @override
  Future<void> updateIdentity(String uid, String displayName, String photoUrl) async {
    final current = await store.watchDocument('accounts/$uid').first;
    if (current == null) return;
    await store.writeBatch([
      DocumentWrite.set('accounts/$uid', {
        ...current,
        'displayName': displayName.trim(),
        'photoUrl': photoUrl.trim(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    ]);
  }
}
