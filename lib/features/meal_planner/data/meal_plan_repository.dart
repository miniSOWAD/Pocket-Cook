import '../models/meal_plan_entry.dart';
abstract interface class MealPlanRepository {
  Stream<List<MealPlanEntry>> watch(String uid);
  Future<void> save(String uid, MealPlanEntry entry);
  Future<void> remove(String uid, String entryId);
}
