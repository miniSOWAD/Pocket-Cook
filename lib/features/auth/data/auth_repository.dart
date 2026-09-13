import '../models/auth_user.dart';

abstract interface class AuthRepository {
  bool get isDemo;
  AuthUser? get currentUser;
  Stream<AuthUser?> get userChanges;
  Future<void> enterDemo();
  Future<void> signIn(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> updateAccountProfile(String displayName, String photoUrl);
  Future<void> requestEmailChange(String email);
  Future<void> signOut();
  Future<void> dispose();
}
