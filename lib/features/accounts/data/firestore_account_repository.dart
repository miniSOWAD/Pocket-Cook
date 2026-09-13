import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/auth_user.dart';
import '../models/app_account.dart';
import 'account_repository.dart';

class FirestoreAccountRepository implements AccountRepository {
  FirestoreAccountRepository(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<AppAccount?> watchAccount(String uid) => firestore
      .doc('accounts/$uid')
      .snapshots()
      .map((snapshot) => snapshot.exists
          ? AppAccount.fromJson(snapshot.id, snapshot.data()!)
          : null);

  @override
  Stream<List<AppAccount>> watchCooks() => firestore
      .collection('accounts')
      .where('status', isEqualTo: 'active')
      .where('role', whereIn: const ['cook', 'admin'])
      .snapshots()
      .map((snapshot) {
        final users = snapshot.docs
            .map((doc) => AppAccount.fromJson(doc.id, doc.data()))
            .toList();
        users.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        return users;
      });

  @override
  Future<void> createVisitor(AuthUser user) async {
    final ref = firestore.doc('accounts/${user.uid}');
    await firestore.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) return;
      final now = DateTime.now().millisecondsSinceEpoch;
      transaction.set(ref, {
        'displayName': user.name.trim().isEmpty ? 'Home cook' : user.name.trim(),
        'photoUrl': user.photoUrl.trim(),
        'role': 'visitor',
        'status': 'active',
        'createdAt': now,
        'updatedAt': now,
      });
    });
  }

  @override
  Future<void> updateIdentity(String uid, String displayName, String photoUrl) =>
      firestore.doc('accounts/$uid').set({
        'displayName': displayName.trim(),
        'photoUrl': photoUrl.trim(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
}
