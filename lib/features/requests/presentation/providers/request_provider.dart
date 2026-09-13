import '../../../../core/errors/app_exception.dart';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/request_repository.dart';
import '../../models/cook_application.dart';
import '../../models/recipe_request.dart';

class RequestProvider extends UserScopedNotifier {
  RequestProvider(this.repository, this.auth, this.accountProvider) {
    attach(auth, () => auth.user?.uid);
  }

  final RequestRepository repository;
  final AuthProvider auth;
  final AccountProvider accountProvider;
  CookApplication? cookApplication;
  List<RecipeRequest> myRecipeRequests = const [];

  @override
  void resetScope() {
    cookApplication = null;
    myRecipeRequests = const [];
  }

  @override
  void bindUser(String uid) {
    watch(repository.watchCookApplication(uid), (value) => cookApplication = value);
    watch(repository.watchMyRecipeRequests(uid), (value) => myRecipeRequests = value);
  }

  Future<bool> becomeCook(String message) => run(() async {
        final uid = requireUser();
        final user = auth.user!;
        if (accountProvider.account == null) {
          final ready = await accountProvider.ensureCurrentAccount();
          if (!ready) throw const AppException('Your account is still being prepared. Please try again.');
        }
        if (!accountProvider.isVisitor) {
          throw const AppException('Only visitor accounts can request the Cook role.');
        }
        if (cookApplication?.isPending == true) {
          throw const AppException('Your Cook request is already waiting for review.');
        }
        await repository.submitCookApplication(uid, user.name, message);
      });

  Future<bool> requestRecipe(String title, String details) => run(() async {
        final uid = requireUser();
        final user = auth.user!;
        if (accountProvider.account == null) {
          final ready = await accountProvider.ensureCurrentAccount();
          if (!ready) throw const AppException('Your account is still being prepared. Please try again.');
        }
        if (title.trim().length < 2 || title.trim().length > 120) {
          throw const AppException('Enter a recipe name between 2 and 120 characters.');
        }
        if (details.trim().length > 600) {
          throw const AppException('Keep request details under 600 characters.');
        }
        await repository.createRecipeRequest(
          requesterUid: uid,
          requesterName: user.name,
          requesterRole: accountProvider.role,
          title: title,
          details: details,
        );
      });
}
