import '../../../core/errors/app_exception.dart';
import '../../accounts/models/app_role.dart';
import '../models/managed_user.dart';
import 'admin_repository.dart';

class DemoAdminRepository implements AdminRepository {
  const DemoAdminRepository();

  Never _unavailable() => throw const AppException(
        'Admin account management requires Firebase mode and deployed Cloud Functions.',
      );

  @override
  Future<List<ManagedUser>> listUsers() async => _unavailable();

  @override
  Future<void> createUser({required String email, required String password, required String displayName, required AppRole role}) async => _unavailable();
  @override
  Future<void> deleteUser(String uid) async => _unavailable();
  @override
  Future<void> setUserBlocked(String uid, bool blocked) async => _unavailable();
  @override
  Future<void> setUserRole(String uid, AppRole role) async => _unavailable();
  @override
  Future<void> reviewCookApplication(String uid, bool approve) async => _unavailable();
}
