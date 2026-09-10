import 'dart:convert';
import '../../recipes/models/ingredient.dart';
import '../models/grocery_item.dart';
import '../models/grocery_source.dart';

abstract final class IngredientMerger {
  // Only exact unit identities and kg/g or l/ml conversions are supported.
  // There are deliberately no cup-to-gram or density guesses.
  static ({String unit, double? quantity}) canonical(Ingredient ingredient) {
    var unit = ingredient.unit.trim().toLowerCase();
    var quantity = ingredient.quantity;
    if (unit == 'kg') { unit = 'g'; quantity = quantity == null ? null : quantity * 1000; }
    if (unit == 'l') { unit = 'ml'; quantity = quantity == null ? null : quantity * 1000; }
    return (unit: unit, quantity: quantity);
  }
  static String keyFor(Ingredient ingredient) {
    final value = canonical(ingredient);
    final raw = '${ingredient.id.toLowerCase().trim()}|${value.unit}|${value.quantity == null ? 'note' : 'amount'}';
    return base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
  }
  static Set<String> keysFor(GrocerySource source) => source.ingredients.map(keyFor).toSet();

  static List<GroceryItem> merge(Iterable<GrocerySource> sources, Set<String> checkedKeys) {
    final buckets = <String, _Bucket>{};
    for (final source in sources) {
      for (final ingredient in source.ingredients) {
        final key = keyFor(ingredient);
        final value = canonical(ingredient);
        final bucket = buckets.putIfAbsent(key, () => _Bucket(ingredient.name, value.unit, value.quantity == null));
        if (value.quantity != null) bucket.quantity += value.quantity!;
        bucket.sources.add(source.id);
      }
    }
    final items = buckets.entries.map((entry) => GroceryItem(
      key: entry.key, name: entry.value.name, unit: entry.value.unit,
      quantity: entry.value.nonNumeric ? null : entry.value.quantity,
      sourceIds: Set.unmodifiable(entry.value.sources), checked: checkedKeys.contains(entry.key),
    )).toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }
}
class _Bucket {
  _Bucket(this.name, this.unit, this.nonNumeric);
  final String name, unit;
  final bool nonNumeric;
  double quantity = 0;
  final Set<String> sources = {};
}
