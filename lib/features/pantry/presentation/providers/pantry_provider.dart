import 'package:uuid/uuid.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../recipes/models/recipe.dart';
import '../../data/pantry_repository.dart';
import '../../logic/pantry_matcher.dart';
import '../../logic/pantry_units.dart';
import '../../models/pantry_item.dart';
import '../../models/pantry_match_result.dart';

class PantryProvider extends UserScopedNotifier {
  PantryProvider(this.repository, AuthProvider auth) { attach(auth, () => auth.user?.uid); }
  final PantryRepository repository;
  List<PantryItem> items = [];

  @override
  void resetScope() { items = []; }

  @override
  void bindUser(String uid) {
    watch(repository.watch(uid), (value) => items = List.unmodifiable(value));
  }

  List<PantryItem> get lowStock => items.where((item) => item.isLowStock).toList();

  List<PantryItem> expiringWithin(int days, {DateTime? now}) {
    final today = DateTime((now ?? DateTime.now()).year, (now ?? DateTime.now()).month, (now ?? DateTime.now()).day);
    final end = today.add(Duration(days: days + 1));
    final result = items.where((item) => item.expiryDate != null &&
      item.expiryDate!.isBefore(end) && !item.expiryDate!.isBefore(today)).toList();
    result.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
    return result;
  }

  PantryMatchResult match(Recipe recipe, {int? servings}) =>
      PantryMatcher.match(recipe, servings ?? recipe.baseServings, items);

  List<PantryMatchResult> rankedMatches(Iterable<Recipe> recipes) {
    final result = recipes.map((recipe) => match(recipe)).toList();
    result.sort((a, b) {
      final percentage = b.matchPercentage.compareTo(a.matchPercentage);
      if (percentage != 0) return percentage;
      return a.recipe.totalMinutes.compareTo(b.recipe.totalMinutes);
    });
    return result;
  }

  Future<bool> save({String? id, required String ingredientId, required String name,
      required double quantity, required String unit, double? lowStockThreshold,
      DateTime? expiryDate, String note = ''}) => run(() async {
    final uid = requireUser();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 120) throw const AppException('Use an item name of 1 to 120 characters.');
    if (ingredientId.trim().isEmpty || ingredientId.length > 80) throw const AppException('Choose a valid ingredient.');
    if (!PantryUnits.supported.contains(unit)) throw const AppException('Choose a supported measurement unit.');
    final invalid = InputValidators.quantity(quantity.toString());
    if (invalid != null) throw AppException(invalid);
    if (lowStockThreshold != null && (!lowStockThreshold.isFinite || lowStockThreshold < 0)) {
      throw const AppException('Low-stock threshold cannot be negative.');
    }
    if (note.length > 240) throw const AppException('Keep notes under 240 characters.');
    final item = PantryItem(id: id ?? 'pantry-${const Uuid().v4()}', ingredientId: ingredientId.trim(),
      name: trimmedName, quantity: quantity, unit: unit, lowStockThreshold: lowStockThreshold,
      expiryDate: expiryDate == null ? null : DateTime(expiryDate.year, expiryDate.month, expiryDate.day),
      note: note.trim(), updatedAt: DateTime.now().millisecondsSinceEpoch);
    await repository.save(uid, item);
  });

  Future<bool> remove(String id) => run(() => repository.remove(requireUser(), id));
}
