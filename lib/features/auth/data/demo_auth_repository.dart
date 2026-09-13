import 'dart:async';
import '../../../core/errors/app_exception.dart';
import '../../../core/storage/key_value_store.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this.storage) {
    final session = storage.read(_key) ?? storage.read(_legacyKey);
    if (session == 'active') {
      _user = demoUser;
      if (storage.read(_key) == null) unawaited(storage.write(_key, 'active'));
    }
  }

  static const _key = 'lizas_kitchen.demo.session';
  static const _legacyKey = 'savor.demo.session';
  static const demoUser = AuthUser(
    uid: 'demo-user',
    name: 'Home cook',
    email: '',
    isDemo: true,
  );

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
  Future<void> signIn(String email, String password) async => throw const AppException(
        'Use Enter demo workspace. Real login requires Firebase mode.',
      );

  @override
  Future<void> register(String name, String email, String password) async =>
      throw const AppException('Account registration requires Firebase mode.');

  @override
  Future<void> resetPassword(String email) async =>
      throw const AppException('Password reset requires Firebase mode.');

  @override
  Future<void> updateAccountProfile(String displayName, String photoUrl) async {
    final current = _user;
    if (current == null) {
      throw const AppException('Enter the demo workspace before editing your profile.');
    }
    _user = AuthUser(
      uid: current.uid,
      name: displayName.trim(),
      email: current.email,
      photoUrl: photoUrl.trim(),
      isDemo: true,
    );
    _changes.add(_user);
  }

  @override
  Future<void> requestEmailChange(String email) async => throw const AppException(
        'Email changes require a real Firebase account.',
      );

  @override
  Future<void> signOut() async {
    await storage.remove(_key);
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> dispose() => _changes.close();
}
