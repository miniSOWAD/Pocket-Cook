import 'package:cloud_functions/cloud_functions.dart';
import '../../accounts/models/app_role.dart';
import '../models/managed_user.dart';
import 'admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository(this.functions);
  final FirebaseFunctions functions;

  HttpsCallable _call(String name) => functions.httpsCallable(name);

  @override
  Future<List<ManagedUser>> listUsers() async {
    final result = await _call('adminListUsers').call();
    final data = Map<String, dynamic>.from(result.data as Map);
    final raw = data['users'] as List? ?? const [];
    return raw
        .map((item) => ManagedUser.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required AppRole role,
  }) async {
    await _call('adminCreateUser').call({
      'email': email.trim(),
      'password': password,
      'displayName': displayName.trim(),
      'role': role.value,
    });
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _call('adminDeleteUser').call({'uid': uid});
  }

  @override
  Future<void> setUserBlocked(String uid, bool blocked) async {
    await _call('adminSetUserBlocked').call({'uid': uid, 'blocked': blocked});
  }

  @override
  Future<void> setUserRole(String uid, AppRole role) async {
    await _call('adminSetUserRole').call({'uid': uid, 'role': role.value});
  }

  @override
  Future<void> reviewCookApplication(String uid, bool approve) async {
    await _call('adminReviewCookApplication').call({'uid': uid, 'approve': approve});
  }
}
