import '../../recipes/models/ingredient.dart';
import '../../recipes/models/recipe.dart';
import '../models/available_ingredient.dart';
import '../models/plate_recipe_match.dart';

class MakePlateMatcher {
  const MakePlateMatcher();

  static const _alwaysAvailable = {'water', 'salt'};

  List<PlateRecipeMatch> match({
    required List<Recipe> recipes,
    required List<AvailableIngredient> available,
  }) {
    if (available.isEmpty) return const [];

    final matches = recipes.map((recipe) => _matchRecipe(recipe, available)).toList()
      ..sort((a, b) {
        if (a.canMakeNow != b.canMakeNow) return a.canMakeNow ? -1 : 1;
        final byScore = b.matchPercent.compareTo(a.matchPercent);
        if (byScore != 0) return byScore;
        final byMissing = (a.missingIngredients.length + a.shortIngredients.length)
            .compareTo(b.missingIngredients.length + b.shortIngredients.length);
        if (byMissing != 0) return byMissing;
        return a.recipe.totalMinutes.compareTo(b.recipe.totalMinutes);
      });

    return matches.where((match) => match.matchPercent >= 25 || match.canMakeNow).toList(growable: false);
  }

  PlateRecipeMatch _matchRecipe(Recipe recipe, List<AvailableIngredient> available) {
    final required = recipe.ingredients
        .where((ingredient) => ingredient.quantity != null && !_alwaysAvailable.contains(_normalize(ingredient.id)))
        .toList(growable: false);

    if (required.isEmpty) {
      return PlateRecipeMatch(
        recipe: recipe,
        matchPercent: 100,
        matchedIngredients: 0,
        requiredIngredients: 0,
        missingIngredients: const [],
        shortIngredients: const [],
      );
    }

    var score = 0.0;
    var fullyMatched = 0;
    final missing = <String>[];
    final short = <String>[];

    for (final ingredient in required) {
      final item = _findAvailable(ingredient, available);
      if (item == null) {
        missing.add(_requiredLabel(ingredient));
        continue;
      }

      if (item.quantity == null) {
        fullyMatched++;
        score += 1;
        continue;
      }

      final requiredQuantity = ingredient.quantity;
      if (requiredQuantity == null) {
        fullyMatched++;
        score += 1;
        continue;
      }

      final converted = _convert(item.quantity!, item.unit, ingredient.unit);
      if (converted == null) {
        // The ingredient is present, but the units are not safely comparable.
        // Treat presence as useful rather than rejecting the match entirely.
        fullyMatched++;
        score += 1;
        continue;
      }

      if (converted + 1e-9 >= requiredQuantity) {
        fullyMatched++;
        score += 1;
      } else {
        final fraction = (converted / requiredQuantity).clamp(0.0, 1.0).toDouble();
        score += 0.55 * fraction;
        short.add('${ingredient.name}: have ${_amount(item.quantity, item.unit)}, need ${_amount(requiredQuantity, ingredient.unit)}');
      }
    }

    final percent = ((score / required.length) * 100).round().clamp(0, 100).toInt();
    return PlateRecipeMatch(
      recipe: recipe,
      matchPercent: percent,
      matchedIngredients: fullyMatched,
      requiredIngredients: required.length,
      missingIngredients: List.unmodifiable(missing),
      shortIngredients: List.unmodifiable(short),
    );
  }

  AvailableIngredient? _findAvailable(Ingredient ingredient, List<AvailableIngredient> available) {
    final ingredientKeys = {
      _normalize(ingredient.id),
      _normalize(ingredient.name),
    }..remove('');

    for (final item in available) {
      final input = _normalize(item.name);
      if (input.isEmpty) continue;
      for (final key in ingredientKeys) {
        if (input == key || _containsPhrase(input, key) || _containsPhrase(key, input)) return item;
      }
    }
    return null;
  }

  bool _containsPhrase(String longer, String shorter) {
    if (shorter.length < 3) return false;
    final longerTokens = longer.split(' ').where((token) => token.isNotEmpty).toSet();
    final shorterTokens = shorter.split(' ').where((token) => token.isNotEmpty).toSet();
    if (shorterTokens.isEmpty) return false;
    return shorterTokens.every(longerTokens.contains);
  }

  String _normalize(String value) {
    var normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    final words = normalized.split(' ').map((word) {
      if (word.length > 4 && word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
      if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) return word.substring(0, word.length - 1);
      return word;
    }).toList();
    normalized = words.join(' ');
    return normalized;
  }

  double? _convert(double value, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase().trim();
    final to = toUnit.toLowerCase().trim();
    if (from == to) return value;
    if (from.isEmpty || to.isEmpty) return null;

    const mass = {'g': 1.0, 'kg': 1000.0};
    const volume = {'ml': 1.0, 'l': 1000.0, 'tsp': 5.0, 'tbsp': 15.0, 'cup': 240.0};
    const count = {'pcs': 1.0};

    if (mass.containsKey(from) && mass.containsKey(to)) {
      return value * mass[from]! / mass[to]!;
    }
    if (volume.containsKey(from) && volume.containsKey(to)) {
      return value * volume[from]! / volume[to]!;
    }
    if (count.containsKey(from) && count.containsKey(to)) return value;
    return null;
  }

  String _requiredLabel(Ingredient ingredient) => '${ingredient.name} · ${_amount(ingredient.quantity, ingredient.unit)}';

  String _amount(double? quantity, String unit) {
    if (quantity == null) return unit;
    final text = (quantity - quantity.round()).abs() < 0.000001
        ? quantity.round().toString()
        : quantity.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return unit.isEmpty ? text : '$text $unit';
  }
}
