import 'dart:math';
import '../../../core/storage/document_store.dart';
import '../../accounts/models/app_role.dart';
import '../models/cook_application.dart';
import '../models/recipe_request.dart';
import 'request_repository.dart';

class LocalRequestRepository implements RequestRepository {
  LocalRequestRepository(this.store);
  final DocumentStore store;

  @override
  Stream<CookApplication?> watchCookApplication(String uid) => store
      .watchDocument('cookApplications/$uid')
      .map((data) => data == null ? null : CookApplication.fromJson(uid, data));

  @override
  Stream<List<CookApplication>> watchAllCookApplications() => store
      .watchCollection('cookApplications')
      .map((docs) => docs.map((d) => CookApplication.fromJson(d.id, d.data)).toList());

  @override
  Stream<List<RecipeRequest>> watchMyRecipeRequests(String uid) => store
      .watchCollection('recipeRequests')
      .map((docs) => docs
          .map((d) => RecipeRequest.fromJson(d.id, d.data))
          .where((request) => request.requesterUid == uid)
          .toList());

  @override
  Stream<List<RecipeRequest>> watchAllRecipeRequests() => store
      .watchCollection('recipeRequests')
      .map((docs) => docs.map((d) => RecipeRequest.fromJson(d.id, d.data)).toList());

  @override
  Future<void> submitCookApplication(String uid, String requesterName, String message) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await store.writeBatch([
      DocumentWrite.set('cookApplications/$uid', {
        'uid': uid,
        'requesterName': requesterName.trim(),
        'message': message.trim(),
        'status': 'pending',
        'createdAt': now,
        'reviewedAt': null,
      }),
    ]);
  }

  @override
  Future<void> createRecipeRequest({
    required String requesterUid,
    required String requesterName,
    required AppRole requesterRole,
    required String title,
    required String details,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = '${now}_${Random().nextInt(999999)}';
    await store.writeBatch([
      DocumentWrite.set('recipeRequests/$id', {
        'requesterUid': requesterUid,
        'requesterName': requesterName.trim(),
        'requesterRole': requesterRole.value,
        'title': title.trim(),
        'details': details.trim(),
        'status': 'pending',
        'createdAt': now,
        'fulfilledRecipeId': '',
      }),
    ]);
  }

  @override
  Future<void> updateRecipeRequestStatus(String requestId, String status, {String fulfilledRecipeId = ''}) async {
    final current = await store.watchDocument('recipeRequests/$requestId').first;
    if (current == null) return;
    await store.writeBatch([
      DocumentWrite.set('recipeRequests/$requestId', {
        ...current,
        'status': status,
        'fulfilledRecipeId': fulfilledRecipeId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    ]);
  }
}
