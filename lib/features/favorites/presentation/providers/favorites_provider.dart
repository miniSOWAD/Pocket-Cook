import '../../../../core/state/user_scoped_notifier.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/favorites_repository.dart';
class FavoritesProvider extends UserScopedNotifier {
  FavoritesProvider(this.repository, AuthProvider auth) { attach(auth, () => auth.user?.uid); }
  final FavoritesRepository repository;
  Set<String> ids = {};
  bool contains(String recipeId) => ids.contains(recipeId);
  @override
  void resetScope() { ids = {}; }
  @override
  void bindUser(String uid) { watch(repository.watchIds(uid), (value) => ids = Set.unmodifiable(value)); }
  Future<bool> toggle(String recipeId) => run(() async {
    final uid = requireUser();
    await repository.setFavorite(uid, recipeId, !contains(recipeId));
  });
}
