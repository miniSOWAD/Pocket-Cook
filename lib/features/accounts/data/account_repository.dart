import '../../auth/models/auth_user.dart';
import '../models/app_account.dart';

abstract interface class AccountRepository {
  Stream<AppAccount?> watchAccount(String uid);
  Stream<List<AppAccount>> watchCooks();
  Future<void> createVisitor(AuthUser user);
  Future<void> updateIdentity(String uid, String displayName, String photoUrl);
}
