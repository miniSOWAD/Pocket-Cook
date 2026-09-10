import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/auth_guard.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/presentation/widgets/serving_selector.dart';
import '../../models/meal_plan_entry.dart';
import '../providers/meal_plan_provider.dart';
Future<void> planRecipe(BuildContext context, Recipe recipe, {int? servings, DateTime? date, MealSlot? slot}) async {
  if (!await ensureSignedIn(context) || !context.mounted) return;
  await showDialog<void>(context: context, builder: (_) => _PlanRecipeDialog(recipe: recipe,
    initialServings: servings ?? recipe.baseServings, initialDate: date ?? DateTime.now(), initialSlot: slot ?? MealSlot.dinner));
}
class _PlanRecipeDialog extends StatefulWidget {
  const _PlanRecipeDialog({required this.recipe, required this.initialServings, required this.initialDate, required this.initialSlot});
  final Recipe recipe;
  final int initialServings;
  final DateTime initialDate;
  final MealSlot initialSlot;
  @override
  State<_PlanRecipeDialog> createState() => _PlanRecipeDialogState();
}
class _PlanRecipeDialogState extends State<_PlanRecipeDialog> {
  late DateTime _date;
  late MealSlot _slot;
  late int _servings;
  @override
  void initState() { super.initState(); _date = dateOnly(widget.initialDate); _slot = widget.initialSlot; _servings = widget.initialServings; }
  @override
  Widget build(BuildContext context) {
    final planner = context.watch<MealPlanProvider>();
    final existing = planner.forSlot(_date, _slot);
    return AlertDialog(title: const Text('Make room on your menu'),
      content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.recipe.title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 18),
          OutlinedButton.icon(icon: const Icon(Icons.calendar_month_outlined), label: Text(friendlyDate(_date)), onPressed: () async {
            final picked = await showDatePicker(context: context, initialDate: _date,
              firstDate: DateTime(1900), lastDate: DateTime(2200));
            if (mounted && picked != null) setState(() => _date = picked);
          }),
          const SizedBox(height: 18), DropdownButtonFormField<MealSlot>(initialValue: _slot,
            decoration: const InputDecoration(labelText: 'Meal'), items: MealSlot.values
              .map((slot) => DropdownMenuItem(value: slot, child: Text(slot.label))).toList(),
            onChanged: (value) { if (value != null) setState(() => _slot = value); }),
          const SizedBox(height: 18), Wrap(spacing: 16, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center,
            children: [const Text('Servings'), ServingSelector(value: _servings, onChanged: (value) => setState(() => _servings = value))]),
          if (existing != null) ...[const SizedBox(height: 18), InfoBanner('This replaces ${existing.recipeTitle} in this meal slot.')],
          const SizedBox(height: 12), ErrorNotice(planner.errorMessage),
        ]))),
      actions: [TextButton(onPressed: planner.busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(label: existing == null ? 'Save meal' : 'Replace meal', icon: Icons.check_rounded, loading: planner.busy,
          onPressed: () async {
            final ok = await planner.save(MealPlanEntry(date: _date, slot: _slot,
              recipeId: widget.recipe.id, recipeTitle: widget.recipe.title, servings: _servings));
            if (context.mounted && ok) { showMessage(context, 'Added to your meal plan.'); Navigator.pop(context); }
          })]);
  }
}
