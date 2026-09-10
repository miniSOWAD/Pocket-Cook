import '../models/user_profile.dart';
abstract interface class ProfileRepository {
  Stream<UserProfile?> watch(String uid);
  Future<void> save(String uid, UserProfile profile);
}
