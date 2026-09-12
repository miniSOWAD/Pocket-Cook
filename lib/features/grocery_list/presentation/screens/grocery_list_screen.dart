import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/serving_selector.dart';
import '../../models/grocery_item.dart';
import '../../models/grocery_source.dart';
import '../providers/grocery_provider.dart';
import '../widgets/add_grocery_item_dialog.dart';
class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    final signedIn = context.watch<AuthProvider>().user != null;
    final items = grocery.items;
    return FeaturePage(title: 'A little list. A better shop.', subtitle: 'Everything your next good meal needs.', eyebrow: 'Your grocery bag',
      child: !signedIn ? const SignInPrompt(message: 'Turn recipes and your weekly menu into a grocery list that adds up.')
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(grocery.errorMessage, onRetry: grocery.retry),
        Wrap(spacing: 12, runSpacing: 10, children: [
          AppButton(label: 'Add item', icon: Icons.add_rounded, onPressed: grocery.busy || grocery.loading ? null : () => editGroceryItem(context)),
          if (grocery.sources.isNotEmpty) OutlinedButton.icon(icon: const Icon(Icons.delete_outline_rounded), label: const Text('Clear list'),
            onPressed: grocery.busy ? null : () async {
              if (!await confirmAction(context, title: 'Clear your grocery list?',
                  message: 'All recipe contributions, manual items, and checkmarks will be removed. Your meal plan stays unchanged.', confirmLabel: 'Clear list')) return;
              final ok = await grocery.clear();
              if (context.mounted && !ok) showMessage(context, grocery.errorMessage ?? 'Could not clear the list.');
            }),
        ]),
        const SizedBox(height: 24),
        if (grocery.loading) const LoadingView()
        else if (items.isEmpty) const EmptyStateView(icon: Icons.shopping_bag_outlined,
          title: 'Your next meal starts with a list', message: 'Add ingredients from a recipe, sync your meal plan, or add an item above.')
        else ...[
          SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${grocery.purchasedCount} of ${items.length} items in your basket', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14), ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: grocery.purchasedCount / items.length, minHeight: 7)),
          ])),
          const SizedBox(height: 25),
          if (items.any((item) => !item.checked)) ...[
            const SectionHeading('Still to pick up'),
            SurfaceCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
              for (final item in items.where((item) => !item.checked)) _GroceryTile(item: item),
            ])),
          ],
          if (items.any((item) => item.checked)) ...[
            const SizedBox(height: 24), const SectionHeading('In your basket'),
            SurfaceCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
              for (final item in items.where((item) => item.checked)) _GroceryTile(item: item),
            ])),
          ],
          const SizedBox(height: 25), SurfaceCard(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ExpansionTile(title: const Text('Where your ingredients come from'),
              subtitle: Text('${grocery.sources.length} recipe and manual contributions'),
              children: [for (final source in grocery.sources) _SourceTile(source: source)])),
          const SizedBox(height: 18), const InfoBanner('Edit a contribution to change quantities. Only compatible units merge; '
            'cups and grams stay separate. Updating a contribution resets its affected checkmarks.'),
        ],
      ]));
  }
}
class _GroceryTile extends StatelessWidget {
  const _GroceryTile({required this.item});
  final GroceryItem item;
  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    return CheckboxListTile(key: ValueKey('grocery-${item.key}'), value: item.checked,
      onChanged: grocery.busy ? null : (_) => grocery.toggle(item), controlAffinity: ListTileControlAffinity.leading,
      title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, decoration: item.checked ? TextDecoration.lineThrough : null)),
      subtitle: Text('${formatQuantity(item.quantity)}${item.quantity == null ? '' : ' ${item.unit}'}'
        '${item.sourceIds.length > 1 ? ' / ${item.sourceIds.length} contributions' : ''}'));
  }
}
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});
  final GrocerySource source;
  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    return ListTile(title: Text(source.title), subtitle: Text(source.id.startsWith('pantry_') ? 'Missing ingredients from Pantry' : source.isManual ? 'Manual item' : '${source.servings} servings'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(tooltip: 'Edit contribution', icon: const Icon(Icons.edit_outlined), onPressed: grocery.busy ? null : () {
          if (source.isManual) {
            if (source.ingredients.length == 1) { editGroceryItem(context, source: source); }
            else { showMessage(context, 'This is a grouped pantry contribution. Remove it or update it again from Pantry.'); }
            return;
          }
          final recipe = context.read<RecipeCatalogProvider>().byId(source.recipeId!);
          if (recipe == null) { showMessage(context, 'This recipe is unavailable. Remove its contribution or add manual items.'); return; }
          showDialog<void>(context: context, builder: (_) => _SourceServingsDialog(source: source, recipe: recipe));
        }),
        IconButton(tooltip: 'Remove contribution', icon: const Icon(Icons.close_rounded), onPressed: grocery.busy ? null : () async {
          if (!await confirmAction(context, title: 'Remove these ingredients?', message: 'Only the contribution from ${source.title} is removed.', confirmLabel: 'Remove')) return;
          final ok = await grocery.removeSource(source.id);
          if (context.mounted && !ok) showMessage(context, grocery.errorMessage ?? 'Could not remove the contribution.');
        }),
      ]));
  }
}
class _SourceServingsDialog extends StatefulWidget {
  const _SourceServingsDialog({required this.source, required this.recipe});
  final GrocerySource source;
  final Recipe recipe;
  @override
  State<_SourceServingsDialog> createState() => _SourceServingsDialogState();
}
class _SourceServingsDialogState extends State<_SourceServingsDialog> {
  late int _servings;
  @override
  void initState() { super.initState(); _servings = widget.source.servings; }
  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    return AlertDialog(title: const Text('Adjust grocery servings'), content: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.source.title), const SizedBox(height: 18),
        ServingSelector(value: _servings, onChanged: (value) => setState(() => _servings = value)),
        const SizedBox(height: 16), const Text('This changes this grocery contribution only, not the meal plan. '
          'Syncing a meal-plan week later restores its planned servings.'),
        const SizedBox(height: 12), ErrorNotice(grocery.errorMessage),
      ])), actions: [TextButton(onPressed: grocery.busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
      AppButton(label: 'Update ingredients', icon: Icons.check_rounded, loading: grocery.busy,
        onPressed: () async {
          final ok = await grocery.addRecipe(widget.recipe, _servings, sourceId: widget.source.id, title: widget.source.title);
          if (context.mounted && ok) Navigator.pop(context);
        })]);
  }
}
