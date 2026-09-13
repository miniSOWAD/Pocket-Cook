import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../core/errors/app_exception.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this.auth);

  final firebase.FirebaseAuth auth;

  AuthUser? _map(firebase.User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          name: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'Home cook',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
        );

  firebase.User get _requiredUser {
    final user = auth.currentUser;
    if (user == null) {
      throw const AppException('Sign in before changing your account details.');
    }
    return user;
  }

  @override
  bool get isDemo => false;

  @override
  AuthUser? get currentUser => _map(auth.currentUser);

  @override
  Stream<AuthUser?> get userChanges => auth.userChanges().map(_map);

  @override
  Future<void> enterDemo() async =>
      throw const AppException('This build uses real Firebase accounts.');

  @override
  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user!.updateDisplayName(name.trim());
    await result.user!.reload();
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
  Future<void> updateAccountProfile(String displayName, String photoUrl) async {
    final user = _requiredUser;
    await user.updateDisplayName(displayName.trim());
    await user.updatePhotoURL(photoUrl.trim().isEmpty ? null : photoUrl.trim());
    await user.reload();
  }

  @override
  Future<void> requestEmailChange(String email) async {
    final nextEmail = email.trim();
    final user = _requiredUser;
    if ((user.email ?? '').toLowerCase() == nextEmail.toLowerCase()) return;
    await user.verifyBeforeUpdateEmail(nextEmail);
  }

  @override
  Future<void> signOut() => auth.signOut();

  @override
  Future<void> dispose() async {}
}
