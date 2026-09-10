import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../core/errors/app_exception.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this.auth);
  final firebase.FirebaseAuth auth;
  AuthUser? _map(firebase.User? user) => user == null ? null : AuthUser(
      uid: user.uid, name: user.displayName ?? 'Home cook', email: user.email ?? '');
  @override
  bool get isDemo => false;
  @override
  AuthUser? get currentUser => _map(auth.currentUser);
  @override
  Stream<AuthUser?> get userChanges => auth.userChanges().map(_map);
  @override
  Future<void> enterDemo() async => throw const AppException('This build uses real Firebase accounts.');
  @override
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }
  @override
  Future<void> register(String name, String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await result.user!.updateDisplayName(name.trim());
  }
  @override
  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      // Do not reveal whether an address is registered.
      if (error.code != 'user-not-found') rethrow;
    }
  }
  @override
  Future<void> signOut() => auth.signOut();
  @override
  Future<void> dispose() async {}
}
