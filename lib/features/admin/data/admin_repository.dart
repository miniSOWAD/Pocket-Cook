import '../../accounts/models/app_role.dart';
import '../models/managed_user.dart';

abstract interface class AdminRepository {
  Future<List<ManagedUser>> listUsers();
  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required AppRole role,
  });
  Future<void> deleteUser(String uid);
  Future<void> setUserBlocked(String uid, bool blocked);
  Future<void> setUserRole(String uid, AppRole role);
  Future<void> reviewCookApplication(String uid, bool approve);
}
