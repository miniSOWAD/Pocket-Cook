import '../../../core/storage/document_store.dart';
import '../models/meal_plan_entry.dart';
import 'meal_plan_repository.dart';
class DocumentMealPlanRepository implements MealPlanRepository {
  DocumentMealPlanRepository(this.store);
  final DocumentStore store;
  @override
  Stream<List<MealPlanEntry>> watch(String uid) => store.watchCollection('users/$uid/mealPlans')
    .map((documents) => documents.map((doc) => MealPlanEntry.fromJson(doc.data)).toList());
  @override
  Future<void> save(String uid, MealPlanEntry entry) => store.writeBatch([
    DocumentWrite.set('users/$uid/mealPlans/${entry.id}', entry.toJson()),
  ]);
  @override
  Future<void> remove(String uid, String entryId) => store.writeBatch([
    DocumentWrite.delete('users/$uid/mealPlans/$entryId'),
  ]);
}
