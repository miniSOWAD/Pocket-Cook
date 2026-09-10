import 'dart:async';
import 'package:recipe_app/features/auth/data/auth_repository.dart';
import 'package:recipe_app/features/auth/models/auth_user.dart';
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._user]);
  AuthUser? _user;
  final controller = StreamController<AuthUser?>.broadcast(sync: true);
  void setUser(String? uid) {
    _user = uid == null ? null : AuthUser(uid: uid, name: uid, email: '$uid@example.test');
    controller.add(_user);
  }
  @override
  bool get isDemo => false;
  @override
  AuthUser? get currentUser => _user;
  @override
  Stream<AuthUser?> get userChanges => controller.stream;
  @override
  Future<void> enterDemo() async { setUser('demo'); }
  @override
  Future<void> signIn(String email, String password) async { setUser(email); }
  @override
  Future<void> register(String name, String email, String password) async { setUser(email); }
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async { setUser(null); }
  @override
  Future<void> dispose() => controller.close();
}
