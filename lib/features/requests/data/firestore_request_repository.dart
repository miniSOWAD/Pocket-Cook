import 'package:cloud_firestore/cloud_firestore.dart';
import '../../accounts/models/app_role.dart';
import '../models/cook_application.dart';
import '../models/recipe_request.dart';
import 'request_repository.dart';

class FirestoreRequestRepository implements RequestRepository {
  FirestoreRequestRepository(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Stream<CookApplication?> watchCookApplication(String uid) => firestore
      .doc('cookApplications/$uid')
      .snapshots()
      .map((doc) => doc.exists ? CookApplication.fromJson(doc.id, doc.data()!) : null);

  @override
  Stream<List<CookApplication>> watchAllCookApplications() => firestore
      .collection('cookApplications')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CookApplication.fromJson(doc.id, doc.data()))
          .toList());

  @override
  Stream<List<RecipeRequest>> watchMyRecipeRequests(String uid) => firestore
      .collection('recipeRequests')
      .where('requesterUid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        final result = snapshot.docs
            .map((doc) => RecipeRequest.fromJson(doc.id, doc.data()))
            .toList();
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return result;
      });

  @override
  Stream<List<RecipeRequest>> watchAllRecipeRequests() => firestore
      .collection('recipeRequests')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RecipeRequest.fromJson(doc.id, doc.data()))
          .toList());

  @override
  Future<void> submitCookApplication(String uid, String requesterName, String message) =>
      firestore.doc('cookApplications/$uid').set({
        'uid': uid,
        'requesterName': requesterName.trim(),
        'message': message.trim(),
        'status': 'pending',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'reviewedAt': null,
      });

  @override
  Future<void> createRecipeRequest({
    required String requesterUid,
    required String requesterName,
    required AppRole requesterRole,
    required String title,
    required String details,
  }) async {
    final ref = firestore.collection('recipeRequests').doc();
    await ref.set({
      'requesterUid': requesterUid,
      'requesterName': requesterName.trim(),
      'requesterRole': requesterRole.value,
      'title': title.trim(),
      'details': details.trim(),
      'status': 'pending',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'fulfilledRecipeId': '',
    });
  }

  @override
  Future<void> updateRecipeRequestStatus(String requestId, String status, {String fulfilledRecipeId = ''}) =>
      firestore.doc('recipeRequests/$requestId').update({
        'status': status,
        'fulfilledRecipeId': fulfilledRecipeId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
}
