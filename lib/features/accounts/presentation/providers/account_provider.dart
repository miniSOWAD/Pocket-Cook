import 'dart:async';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/account_repository.dart';
import '../../models/app_account.dart';
import '../../models/app_role.dart';

class AccountProvider extends UserScopedNotifier {
  AccountProvider(this.repository, this.auth) {
    attach(auth, () => auth.user?.uid);
  }

  final AccountRepository repository;
  final AuthProvider auth;
  AppAccount? account;
  String? _creatingUid;
  bool _sawAccount = false;
  bool _receivedFirstSnapshot = false;

  AppRole get role => account?.role ?? AppRole.visitor;
  bool get isAdmin => account?.isAdmin == true && account?.isActive == true;
  bool get isCook => account?.isCook == true && account?.isActive == true;
  bool get isVisitor => account?.isVisitor == true && account?.isActive == true;
  bool get roleReady => account != null;
  String get roleLabel => account?.role.label ?? (loading ? 'Loading role' : 'Role unavailable');
  bool get canManageRecipes => account?.canManageRecipes == true;
  bool get isBlocked => account?.status == AccountStatus.blocked;

  @override
  void resetScope() {
    account = null;
    _creatingUid = null;
    _sawAccount = false;
    _receivedFirstSnapshot = false;
  }

  @override
  void bindUser(String uid) {
    watch(repository.watchAccount(uid), (value) {
      final firstSnapshot = !_receivedFirstSnapshot;
      _receivedFirstSnapshot = true;
      if (value != null) _sawAccount = true;
      account = value;
      // Create a Visitor record only for a newly signed-in account that never
      // had an account document. Never recreate a document that an Admin has
      // just deleted while an old auth token is still alive.
      if (firstSnapshot && value == null && !_sawAccount && _creatingUid != uid) {
        final current = auth.user;
        if (current != null && current.uid == uid) {
          _creatingUid = uid;
          unawaited(_createVisitor(current.uid));
        }
      }
    });
  }

  Future<void> _createVisitor(String uid) async {
    final current = auth.user;
    if (current == null || current.uid != uid) return;
    try {
      await repository.createVisitor(current);
      if (account == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        account = AppAccount(
          uid: current.uid,
          displayName: current.name.trim().isEmpty ? 'Home cook' : current.name.trim(),
          photoUrl: current.photoUrl.trim(),
          role: AppRole.visitor,
          status: AccountStatus.active,
          createdAt: now,
          updatedAt: now,
        );
        _sawAccount = true;
        notify();
      }
    } catch (error) {
      reportError(error);
    } finally {
      if (_creatingUid == uid) _creatingUid = null;
    }
  }

  Future<bool> ensureCurrentAccount() => run(() async {
        if (account != null) return;
        final current = auth.user;
        if (current == null) return;
        await repository.createVisitor(current);
        if (account == null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          account = AppAccount(
            uid: current.uid,
            displayName: current.name.trim().isEmpty ? 'Home cook' : current.name.trim(),
            photoUrl: current.photoUrl.trim(),
            role: AppRole.visitor,
            status: AccountStatus.active,
            createdAt: now,
            updatedAt: now,
          );
          _sawAccount = true;
          notify();
        }
      });

  Future<bool> syncIdentity() => run(() async {
        final current = auth.user;
        if (current == null) return;
        await repository.updateIdentity(
          current.uid,
          current.name,
          current.photoUrl,
        );
      });
}
