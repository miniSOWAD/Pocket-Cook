import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../grocery_list/models/grocery_source.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/recipe_image.dart';
import '../../models/meal_plan_entry.dart';
import '../providers/meal_plan_provider.dart';
import '../widgets/plan_recipe_dialog.dart';
import '../widgets/select_recipe_sheet.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}
class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _selected = dateOnly(DateTime.now());
  Future<void> _add(MealSlot slot) async {
    final recipe = await selectRecipe(context);
    if (recipe != null && mounted) await planRecipe(context, recipe, date: _selected, slot: slot);
  }
  @override
  Widget build(BuildContext context) {
    final planner = context.watch<MealPlanProvider>();
    final groceries = context.watch<GroceryProvider>();
    final catalog = context.watch<RecipeCatalogProvider>();
    final start = weekStart(_selected);
    final entries = planner.forWeek(start);
    return FeaturePage(title: 'A good week starts here.', subtitle: 'Less deciding. More enjoying your meals.', eyebrow: 'Your weekly menu',
      child: context.watch<AuthProvider>().user == null ? const SignInPrompt(message: 'Plan breakfast, lunch, dinner, and snacks for the week ahead.')
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(planner.errorMessage, onRetry: planner.retry), ErrorNotice(groceries.errorMessage, onRetry: groceries.retry),
        if (planner.loading) const LoadingView() else ...[
          SurfaceCard(child: Column(children: [
            Row(children: [IconButton(tooltip: 'Previous week', onPressed: () => setState(() => _selected = addCalendarDays(_selected, -7)),
                icon: const Icon(Icons.chevron_left_rounded)),
              Expanded(child: Text(weekLabel(start), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
              IconButton(tooltip: 'Next week', onPressed: () => setState(() => _selected = addCalendarDays(_selected, 7)),
                icon: const Icon(Icons.chevron_right_rounded))]),
            const SizedBox(height: 14), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
              for (var index = 0; index < 7; index++) Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(label: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: [
                  Text(shortWeekdays[index], style: const TextStyle(fontSize: 11)), const SizedBox(height: 5),
                  Text('${addCalendarDays(start, index).day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ])), selected: dateKey(_selected) == dateKey(addCalendarDays(start, index)),
                  onSelected: (_) => setState(() => _selected = addCalendarDays(start, index)))),
            ])),
            const SizedBox(height: 10), TextButton(onPressed: () => setState(() => _selected = dateOnly(DateTime.now())), child: const Text('Back to today')),
          ])),
          const SizedBox(height: 26), SectionHeading(friendlyDate(_selected)),
          for (final slot in MealSlot.values) Padding(padding: const EdgeInsets.only(bottom: 16),
            child: _MealSlotCard(slot: slot, entry: planner.forSlot(_selected, slot), onAdd: () => _add(slot))),
          const SizedBox(height: 16), SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${entries.length} meals planned this week', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10), const Text('Sync this week to update its grocery contributions. '
              'Other weeks and manually added ingredients are kept.'),
            const SizedBox(height: 18), AppButton(label: 'Sync week to groceries', icon: Icons.shopping_bag_outlined,
              loading: groceries.busy, onPressed: groceries.loading || catalog.loading ? null : () async {
                final incoming = <GrocerySource>[];
                for (final entry in entries) {
                  final recipe = catalog.byId(entry.recipeId);
                  if (recipe == null) {
                    showMessage(context, 'A planned recipe is unavailable. Replace or remove it before syncing.');
                    return;
                  }
                  incoming.add(GrocerySource.fromRecipe(recipe, entry.servings, sourceId: 'plan_${entry.id}',
                    title: '${recipe.title} / ${friendlyDate(entry.date)} ${entry.slot.label}'));
                }
                if (incoming.isEmpty && !await confirmAction(context, title: 'Sync an empty week?',
                    message: 'This removes previously imported grocery contributions for this week only.', confirmLabel: 'Sync week')) return;
                if (!context.mounted) return;
                final ok = await groceries.syncWeek(start, incoming);
                if (context.mounted) showMessage(context, ok ? 'This week is synced to your grocery list.' : groceries.errorMessage ?? 'Please try again.');
              }),
          ])),
        ],
      ]));
  }
}
class _MealSlotCard extends StatelessWidget {
  const _MealSlotCard({required this.slot, this.entry, required this.onAdd});
  final MealSlot slot;
  final MealPlanEntry? entry;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final planner = context.watch<MealPlanProvider>();
    final recipe = entry == null ? null : context.watch<RecipeCatalogProvider>().byId(entry!.recipeId);
    return SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Eyebrow(slot.label)),
        if (entry == null) IconButton(tooltip: 'Add ${slot.label.toLowerCase()}', onPressed: planner.busy ? null : onAdd,
          icon: const Icon(Icons.add_circle_outline_rounded))
        else ...[
          IconButton(tooltip: 'Change ${slot.label.toLowerCase()}', onPressed: planner.busy ? null : onAdd, icon: const Icon(Icons.edit_outlined)),
          IconButton(tooltip: 'Remove ${slot.label.toLowerCase()}', onPressed: planner.busy ? null : () async {
            if (!await confirmAction(context, title: 'Remove planned meal?', message: 'Sync this week again to update imported groceries.', confirmLabel: 'Remove')) return;
            final ok = await planner.remove(entry!.id);
            if (context.mounted && !ok) showMessage(context, planner.errorMessage ?? 'Could not remove the meal.');
          }, icon: const Icon(Icons.delete_outline_rounded)),
        ]]),
      if (entry == null) Text('Leave room for something delicious.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
      else InkWell(borderRadius: BorderRadius.circular(12),
        onTap: recipe == null ? null : () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: recipe),
        child: Padding(padding: const EdgeInsets.only(top: 9), child: Row(children: [
          if (recipe != null) ...[ClipRRect(borderRadius: BorderRadius.circular(15),
            child: SizedBox(width: 82, height: 76, child: RecipeImage(recipe: recipe))), const SizedBox(width: 16)],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry!.recipeTitle, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5),
            Text(recipe == null ? 'Recipe is unavailable' : '${entry!.servings} servings / ${recipe.totalMinutes} min'),
            if (recipe != null) TextButton(onPressed: () => planRecipe(context, recipe,
                servings: entry!.servings, date: entry!.date, slot: entry!.slot), child: const Text('Adjust servings')),
          ])),
        ]))),
    ]));
  }
}
