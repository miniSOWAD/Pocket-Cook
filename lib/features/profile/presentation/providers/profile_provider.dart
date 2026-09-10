import '../../../../core/errors/app_exception.dart';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/profile_repository.dart';
import '../../models/user_profile.dart';
class ProfileProvider extends UserScopedNotifier {
  ProfileProvider(this.repository, AuthProvider auth) { attach(auth, () => auth.user?.uid); }
  final ProfileRepository repository;
  UserProfile? profile;
  @override
  void resetScope() { profile = null; }
  @override
  void bindUser(String uid) { watch(repository.watch(uid), (value) => profile = value); }
  Future<bool> save(String name, String bio) => run(() async {
    final uid = requireUser();
    final invalid = InputValidators.name(name);
    if (invalid != null) throw AppException(invalid);
    if (bio.length > 240) throw const AppException('Keep your bio under 240 characters.');
    await repository.save(uid, UserProfile(displayName: name.trim(), bio: bio.trim()));
  });
}
