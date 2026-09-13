import 'dart:async';
import '../../../../core/state/async_notifier.dart';
import '../../data/request_repository.dart';
import '../../models/cook_application.dart';
import '../../models/recipe_request.dart';

class StaffRequestsProvider extends AsyncNotifier {
  StaffRequestsProvider(this.repository) {
    _cookSubscription = repository.watchAllCookApplications().listen(
      (value) {
        cookApplications = value;
        notify();
      },
      onError: (Object error, StackTrace stack) => reportError(error),
    );
    _recipeSubscription = repository.watchAllRecipeRequests().listen(
      (value) {
        recipeRequests = value;
        notify();
      },
      onError: (Object error, StackTrace stack) => reportError(error),
    );
  }

  final RequestRepository repository;
  late final StreamSubscription<List<CookApplication>> _cookSubscription;
  late final StreamSubscription<List<RecipeRequest>> _recipeSubscription;
  List<CookApplication> cookApplications = const [];
  List<RecipeRequest> recipeRequests = const [];

  List<RecipeRequest> get pendingRecipeRequests => recipeRequests
      .where((request) => request.status == 'pending' || request.status == 'accepted')
      .toList();

  Future<bool> setRecipeStatus(String id, String status, {String fulfilledRecipeId = ''}) =>
      run(() => repository.updateRecipeRequestStatus(id, status, fulfilledRecipeId: fulfilledRecipeId));

  @override
  void dispose() {
    _cookSubscription.cancel();
    _recipeSubscription.cancel();
    super.dispose();
  }
}
