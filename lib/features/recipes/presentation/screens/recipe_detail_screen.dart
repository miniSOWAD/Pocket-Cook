import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/router/auth_guard.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../cooking/presentation/screens/cooking_screen.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../meal_planner/presentation/widgets/plan_recipe_dialog.dart';
import '../providers/recipe_detail_provider.dart';
import '../widgets/recipe_image.dart';
import '../widgets/serving_selector.dart';
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}
class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _ingredients = true;
  @override
  Widget build(BuildContext context) {
    final detail = context.watch<RecipeDetailProvider>();
    final recipe = detail.recipe;
    final groceries = context.watch<GroceryProvider>();
    return Scaffold(appBar: AppBar(title: const Text('In the cookbook'), actions: [FavoriteButton(recipeId: recipe.id), const SizedBox(width: 12)]),
      bottomNavigationBar: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: AppButton(label: 'Start cooking', icon: Icons.play_arrow_rounded,
          onPressed: recipe.steps.isEmpty ? null : () => Navigator.pushNamed(context, AppRoutes.cooking,
            arguments: CookingArguments(recipe, detail.servings))))),
      body: SafeArea(child: SingleChildScrollView(child: Align(alignment: Alignment.topCenter,
        child: Container(constraints: const BoxConstraints(maxWidth: 900), padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(26), child: AspectRatio(aspectRatio: 1.65, child: RecipeImage(recipe: recipe))),
            const SizedBox(height: 25), Eyebrow(recipe.categoryId), const SizedBox(height: 10),
            Text(recipe.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12), Text(recipe.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18), Wrap(spacing: 10, runSpacing: 8, children: [
              Chip(avatar: const Icon(Icons.schedule_rounded, size: 17), label: Text('${recipe.totalMinutes} min total')),
              Chip(avatar: const Icon(Icons.restaurant_rounded, size: 17), label: Text(recipe.difficulty)),
              if (recipe.vegetarian) const Chip(avatar: Icon(Icons.eco_outlined, size: 17), label: Text('Vegetarian')),
            ]),
            const SizedBox(height: 20), SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text('How many servings?', style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(width: 8), ServingSelector(value: detail.servings, onChanged: detail.setServings)]),
              const SizedBox(height: 10), Text('Ingredient amounts scale. Cooking times do not.', style: Theme.of(context).textTheme.bodySmall),
            ])),
            const SizedBox(height: 20), Wrap(spacing: 12, runSpacing: 10, children: [
              OutlinedButton.icon(icon: const Icon(Icons.shopping_bag_outlined), label: const Text('Add to groceries'),
                onPressed: groceries.busy ? null : () async {
                  if (!await ensureSignedIn(context) || !context.mounted) return;
                  final ok = await groceries.addRecipe(recipe, detail.servings);
                  if (context.mounted) showMessage(context, ok ? 'Ingredients added. Re-adding updates this recipe, not its quantity twice.'
                    : groceries.errorMessage ?? 'Please try again.');
                }),
              OutlinedButton.icon(icon: const Icon(Icons.calendar_month_outlined), label: const Text('Plan this meal'),
                onPressed: () => planRecipe(context, recipe, servings: detail.servings)),
            ]),
            const SizedBox(height: 28), SegmentedButton<bool>(segments: const [
              ButtonSegment(value: true, label: Text('Ingredients'), icon: Icon(Icons.checklist_rounded)),
              ButtonSegment(value: false, label: Text('Instructions'), icon: Icon(Icons.menu_book_rounded)),
            ], selected: {_ingredients}, onSelectionChanged: (value) => setState(() => _ingredients = value.first)),
            const SizedBox(height: 22),
            if (_ingredients) ...[
              for (final ingredient in detail.ingredients) Padding(padding: const EdgeInsets.only(bottom: 14),
                child: SurfaceCard(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), child: Row(children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (ingredient.note.isNotEmpty) Text(ingredient.note, style: Theme.of(context).textTheme.bodySmall),
                  ])), const SizedBox(width: 12), Text('${formatQuantity(ingredient.quantity)}${ingredient.quantity == null ? '' : ' ${ingredient.unit}'}',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                ]))),
            ] else ...[
              for (final step in recipe.steps.asMap().entries) Padding(padding: const EdgeInsets.only(bottom: 20),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(radius: 17, child: Text('${step.key + 1}')), const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(step.value.title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5),
                    Text(step.value.instruction),
                    if (step.value.timerSeconds > 0) Padding(padding: const EdgeInsets.only(top: 8),
                      child: Text('Timer: ${(step.value.timerSeconds / 60).ceil()} min', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                  ])),
                ])),
            ],
            const SizedBox(height: 12), const InfoBanner('Check ingredient labels for allergens. Adjust seasoning to your taste; '
              'these sample recipes do not include verified nutrition data.'),
            const SizedBox(height: 20),
          ]))))));
  }
}
