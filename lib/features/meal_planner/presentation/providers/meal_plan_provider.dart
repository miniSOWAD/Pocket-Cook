import '../../../../core/errors/app_exception.dart';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/meal_plan_repository.dart';
import '../../models/meal_plan_entry.dart';
class MealPlanProvider extends UserScopedNotifier {
  MealPlanProvider(this.repository, AuthProvider auth) { attach(auth, () => auth.user?.uid); }
  final MealPlanRepository repository;
  List<MealPlanEntry> entries = [];
  @override
  void resetScope() { entries = []; }
  @override
  void bindUser(String uid) { watch(repository.watch(uid), (value) => entries = List.unmodifiable(value)); }
  MealPlanEntry? forSlot(DateTime date, MealSlot slot) {
    final key = dateKey(date);
    for (final entry in entries) { if (dateKey(entry.date) == key && entry.slot == slot) return entry; }
    return null;
  }
  List<MealPlanEntry> forWeek(DateTime start) {
    final first = dateOnly(start), end = addCalendarDays(start, 7);
    return entries.where((entry) => !entry.date.isBefore(first) && entry.date.isBefore(end)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }
  Future<bool> save(MealPlanEntry entry) => run(() async {
    final uid = requireUser();
    if (entry.servings < 1 || entry.servings > 12) throw const AppException('Choose 1 to 12 servings.');
    await repository.save(uid, entry);
  });
  Future<bool> remove(String entryId) => run(() => repository.remove(requireUser(), entryId));
}
