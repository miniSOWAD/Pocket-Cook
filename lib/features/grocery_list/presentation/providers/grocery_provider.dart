import 'package:uuid/uuid.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/state/user_scoped_notifier.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../recipes/models/ingredient.dart';
import '../../../recipes/models/recipe.dart';
import '../../data/grocery_repository.dart';
import '../../logic/ingredient_merger.dart';
import '../../models/grocery_item.dart';
import '../../models/grocery_source.dart';

class GroceryProvider extends UserScopedNotifier {
  GroceryProvider(this.repository, AuthProvider auth) { attach(auth, () => auth.user?.uid); }
  final GroceryRepository repository;
  List<GrocerySource> sources = [];
  Set<String> checkedKeys = {};
  List<GroceryItem> get items => IngredientMerger.merge(sources, checkedKeys);
  int get purchasedCount => items.where((item) => item.checked).length;
  @override
  void resetScope() { sources = []; checkedKeys = {}; }
  @override
  void bindUser(String uid) {
    watch(repository.watchSources(uid), (value) => sources = List.unmodifiable(value));
    watch(repository.watchCheckedKeys(uid), (value) => checkedKeys = Set.unmodifiable(value));
  }

  Future<void> _save(String uid, List<GrocerySource> incoming, {Set<String> removeIds = const {}}) async {
    if (incoming.any((source) => source.ingredients.isEmpty)) {
      throw const AppException('A grocery contribution must contain an ingredient.');
    }
    final changedIds = {...removeIds, ...incoming.map((source) => source.id)};
    final resetKeys = <String>{
      for (final source in sources.where((source) => changedIds.contains(source.id))) ...IngredientMerger.keysFor(source),
      for (final source in incoming) ...IngredientMerger.keysFor(source),
    };
    await repository.saveSources(uid, incoming, resetKeys: resetKeys, removeSourceIds: removeIds);
  }

  Future<bool> addRecipe(Recipe recipe, int servings, {String? sourceId, String? title}) => run(() async {
    final uid = requireUser();
    await _save(uid, [GrocerySource.fromRecipe(recipe, servings, sourceId: sourceId, title: title)]);
  });

  Future<bool> addIngredients(String title, List<Ingredient> ingredients, {String? sourceId}) => run(() async {
    final uid = requireUser();
    if (title.trim().isEmpty || title.length > 180) throw const AppException('Use a grocery title of 1 to 180 characters.');
    if (ingredients.isEmpty || ingredients.length > 80) throw const AppException('Choose at least one missing ingredient.');
    final source = GrocerySource(id: sourceId ?? 'pantry-${const Uuid().v4()}', title: title.trim(),
      servings: 1, updatedAt: DateTime.now().millisecondsSinceEpoch, ingredients: ingredients);
    await _save(uid, [source]);
  });

  Future<bool> saveManual(String name, double quantity, String unit, {String? sourceId}) => run(() async {
    final uid = requireUser();
    if (name.trim().isEmpty || name.trim().length > 80) throw const AppException('Use an item name of 1 to 80 characters.');
    if (!const {'pcs', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup'}.contains(unit)) {
      throw const AppException('Choose a supported measurement unit.');
    }
    final invalid = InputValidators.quantity(quantity.toString());
    if (invalid != null) throw AppException(invalid);
    final ingredientId = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    final source = GrocerySource(id: sourceId ?? 'manual-${const Uuid().v4()}',
      title: name.trim(), servings: 1, updatedAt: DateTime.now().millisecondsSinceEpoch,
      ingredients: [Ingredient(id: ingredientId.isEmpty ? 'item-${const Uuid().v4()}' : ingredientId,
        name: name.trim(), quantity: quantity, unit: unit)]);
    await _save(uid, [source]);
  });

  Future<bool> syncWeek(DateTime start, List<GrocerySource> incoming) => run(() async {
    final uid = requireUser();
    final prefixes = List.generate(7, (index) => 'plan_${dateKey(addCalendarDays(start, index))}_');
    final incomingIds = incoming.map((source) => source.id).toSet();
    final removeIds = sources.where((source) => prefixes.any(source.id.startsWith) && !incomingIds.contains(source.id))
      .map((source) => source.id).toSet();
    await _save(uid, incoming, removeIds: removeIds);
  });

  Future<bool> removeSource(String id) => run(() => _save(requireUser(), [], removeIds: {id}));
  Future<bool> toggle(GroceryItem item) => run(() => repository.setChecked(requireUser(), item.key, !item.checked));
  Future<bool> clear() => run(() => repository.clear(requireUser(), sources.map((source) => source.id).toList(), Set.of(checkedKeys)));
}
