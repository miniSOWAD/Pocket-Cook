import 'dart:async';
import '../../../../core/state/async_notifier.dart';
import '../../data/auth_repository.dart';
import '../../models/auth_user.dart';

class AuthProvider extends AsyncNotifier {
  AuthProvider(this.repository) {
    _user = repository.currentUser;
    _subscription = repository.userChanges.listen(
      (user) {
        _user = user;
        notify();
      },
      onError: (Object error, StackTrace stack) => reportError(error),
    );
  }

  final AuthRepository repository;
  late final StreamSubscription<AuthUser?> _subscription;
  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isDemo => repository.isDemo;

  Future<void> _withRefresh(Future<void> Function() action) async {
    await action();
    _user = repository.currentUser;
    notify();
  }

  Future<bool> enterDemo() => run(() => _withRefresh(repository.enterDemo));

  Future<bool> signIn(String email, String password) =>
      run(() => _withRefresh(() => repository.signIn(email, password)));

  Future<bool> register(String name, String email, String password) =>
      run(() => _withRefresh(() => repository.register(name, email, password)));

  Future<bool> resetPassword(String email) =>
      run(() => repository.resetPassword(email));

  Future<bool> updateAccountProfile(String displayName, String photoUrl) =>
      run(() => _withRefresh(
            () => repository.updateAccountProfile(displayName, photoUrl),
          ));

  Future<bool> requestEmailChange(String email) =>
      run(() => repository.requestEmailChange(email));

  Future<bool> signOut() => run(() => _withRefresh(repository.signOut));

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
