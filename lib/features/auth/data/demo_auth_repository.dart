import 'dart:async';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/key_value_store.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this.storage) {
    if (storage.read(_key) == 'active') _user = demoUser;
  }
  static const _key = 'savor.demo.session';
  static const demoUser = AuthUser(uid: 'demo-user', name: 'Home cook', email: '', isDemo: true);
  final KeyValueStore storage;
  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast(sync: true);
  @override
  bool get isDemo => true;
  @override
  AuthUser? get currentUser => _user;
  @override
  Stream<AuthUser?> get userChanges => _changes.stream;
  @override
  Future<void> enterDemo() async {
    await storage.write(_key, 'active');
    _user = demoUser;
    _changes.add(_user);
  }
  @override
  Future<void> signIn(String email, String password) async => throw const AppException('Use Enter demo workspace. Real login requires Firebase mode.');
  @override
  Future<void> register(String name, String email, String password) async => throw const AppException('Account registration requires Firebase mode.');
  @override
  Future<void> resetPassword(String email) async => throw const AppException('Password reset requires Firebase mode.');
  @override
  Future<void> signOut() async {
    await storage.remove(_key);
    _user = null;
    _changes.add(null);
  }
  @override
  Future<void> dispose() => _changes.close();
}
