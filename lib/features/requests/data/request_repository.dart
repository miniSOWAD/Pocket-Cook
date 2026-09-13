import '../../accounts/models/app_role.dart';
import '../models/cook_application.dart';
import '../models/recipe_request.dart';

abstract interface class RequestRepository {
  Stream<CookApplication?> watchCookApplication(String uid);
  Stream<List<CookApplication>> watchAllCookApplications();
  Stream<List<RecipeRequest>> watchMyRecipeRequests(String uid);
  Stream<List<RecipeRequest>> watchAllRecipeRequests();
  Future<void> submitCookApplication(String uid, String requesterName, String message);
  Future<void> createRecipeRequest({
    required String requesterUid,
    required String requesterName,
    required AppRole requesterRole,
    required String title,
    required String details,
  });
  Future<void> updateRecipeRequestStatus(String requestId, String status, {String fulfilledRecipeId});
}
