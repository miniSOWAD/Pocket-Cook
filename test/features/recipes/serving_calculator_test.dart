import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/features/recipes/logic/serving_calculator.dart';
import 'package:pocket_cook/features/recipes/presentation/providers/recipe_detail_provider.dart';
import 'package:pocket_cook/core/utils/quantity_formatter.dart';
import '../../helpers/fixtures.dart';
void main() {
  test('scales from two servings to five', () => expect(ServingCalculator.scale(200, 2, 5), 500));
  test('keeps nonnumeric ingredients nonnumeric', () => expect(ServingCalculator.scale(null, 2, 5), isNull));
  test('preserves fractional quantities', () => expect(ServingCalculator.scale(0.5, 2, 3), 0.75));
  test('rejects invalid serving counts', () {
    expect(() => ServingCalculator.scale(100, 0, 2), throwsArgumentError);
    expect(() => ServingCalculator.scale(100, 2, 0), throwsArgumentError);
    expect(() => ServingCalculator.scale(100, 2, 13), throwsArgumentError);
  });
  test('rejects non-finite quantities', () => expect(() => ServingCalculator.scale(double.nan, 2, 3), throwsArgumentError));
  test('changing servings back does not compound rounding', () {
    final detail = RecipeDetailProvider(sampleRecipe());
    detail.setServings(5); expect(detail.ingredients.first.quantity, 500);
    detail.setServings(2); expect(detail.ingredients.first.quantity, 200);
    expect(detail.recipe.ingredients.first.quantity, 200);
    detail.dispose();
  });
  test('quantity formatting is compact', () {
    expect(formatQuantity(2), '2'); expect(formatQuantity(1.25), '1.25');
    expect(formatQuantity(null), 'to taste');
  });
}
