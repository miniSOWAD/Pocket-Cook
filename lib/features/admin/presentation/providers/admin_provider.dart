import '../../../../core/state/async_notifier.dart';
import '../../../accounts/models/app_role.dart';
import '../../data/admin_repository.dart';
import '../../models/managed_user.dart';

class AdminProvider extends AsyncNotifier {
  AdminProvider(this.repository);
  final AdminRepository repository;

  List<ManagedUser> users = const [];

  Future<bool> loadUsers() => run(() async {
        users = await repository.listUsers();
        users.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
      });

  Future<bool> createUser({
    required String email,
    required String password,
    required String displayName,
    required AppRole role,
  }) => run(() async {
        await repository.createUser(
          email: email,
          password: password,
          displayName: displayName,
          role: role,
        );
        users = await repository.listUsers();
      });

  Future<bool> deleteUser(String uid) => run(() async {
        await repository.deleteUser(uid);
        users = await repository.listUsers();
      });

  Future<bool> setBlocked(String uid, bool blocked) => run(() async {
        await repository.setUserBlocked(uid, blocked);
        users = await repository.listUsers();
      });

  Future<bool> setRole(String uid, AppRole role) => run(() async {
        await repository.setUserRole(uid, role);
        users = await repository.listUsers();
      });

  Future<bool> reviewCookApplication(String uid, bool approve) => run(() async {
        await repository.reviewCookApplication(uid, approve);
        users = await repository.listUsers();
      });
}
