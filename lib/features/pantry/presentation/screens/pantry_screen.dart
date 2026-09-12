import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../recipes/models/ingredient.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/recipe_image.dart';
import '../../models/pantry_item.dart';
import '../../models/pantry_match_result.dart';
import '../providers/pantry_provider.dart';
import '../widgets/edit_pantry_item_dialog.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});
  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pantry = context.watch<PantryProvider>();
    final catalog = context.watch<RecipeCatalogProvider>();
    final expiring = pantry.expiringWithin(7);
    final filtered = switch (_filter) {
      1 => pantry.lowStock,
      2 => expiring,
      _ => pantry.items,
    };
    final matches = pantry.rankedMatches(catalog.recipes).take(5).toList();

    return FeaturePage(title: 'Cook from what you have.',
      subtitle: 'Track your kitchen, spot low stock, and find recipes before you shop.',
      eyebrow: 'My pantry',
      trailing: auth.user == null ? null : IconButton.filledTonal(tooltip: 'Add pantry item',
        onPressed: pantry.busy ? null : () => editPantryItem(context), icon: const Icon(Icons.add_rounded)),
      child: auth.user == null
        ? const SignInPrompt(message: 'Keep a private kitchen inventory and discover recipes that match what you already have.')
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ErrorNotice(pantry.errorMessage, onRetry: pantry.retry),
            if (pantry.loading || catalog.loading) const LoadingView() else ...[
              Wrap(spacing: 10, runSpacing: 10, children: [
                _StatChip(icon: Icons.kitchen_outlined, label: '${pantry.items.length} items'),
                _StatChip(icon: Icons.inventory_2_outlined, label: '${pantry.lowStock.length} low stock'),
                _StatChip(icon: Icons.event_busy_outlined, label: '${expiring.length} expiring soon'),
              ]),
              const SizedBox(height: 24),
              SegmentedButton<int>(segments: const [
                ButtonSegment(value: 0, label: Text('All'), icon: Icon(Icons.list_alt_rounded)),
                ButtonSegment(value: 1, label: Text('Low stock'), icon: Icon(Icons.trending_down_rounded)),
                ButtonSegment(value: 2, label: Text('Expiring'), icon: Icon(Icons.schedule_rounded)),
              ], selected: {_filter}, onSelectionChanged: (value) => setState(() => _filter = value.first)),
              const SizedBox(height: 20),
              if (filtered.isEmpty)
                EmptyStateView(icon: Icons.kitchen_outlined,
                  title: _filter == 0 ? 'Your pantry is ready for its first item' : 'Nothing to worry about here',
                  message: _filter == 0 ? 'Add ingredients you keep at home. Match them to recipe ingredients for the best suggestions.'
                    : 'No pantry items match this filter right now.',
                  action: _filter == 0 ? AppButton(label: 'Add pantry item', icon: Icons.add_rounded, onPressed: () => editPantryItem(context)) : null)
              else SurfaceCard(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(children: [
                for (final item in filtered) _PantryTile(item: item),
              ])),
              const SizedBox(height: 32),
              const SectionHeading('Best matches from your kitchen'),
              if (matches.isEmpty)
                const EmptyStateView(title: 'No recipes available', message: 'Recipe suggestions will appear here when the cookbook is ready.')
              else ...[
                for (final result in matches) Padding(padding: const EdgeInsets.only(bottom: 14), child: _MatchCard(result: result)),
                const InfoBanner('Recipe readiness uses matching ingredient IDs and compatible units. Grams/kilograms and milliliters/liters convert automatically; cups are never guessed into grams.'),
              ],
            ],
          ]));
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 18), label: Text(label));
}

class _PantryTile extends StatelessWidget {
  const _PantryTile({required this.item});
  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final today = DateTime.now();
    final expiry = item.expiryDate;
    final expired = expiry != null && expiry.isBefore(DateTime(today.year, today.month, today.day));
    return ListTile(
      leading: CircleAvatar(child: Icon(item.isLowStock ? Icons.trending_down_rounded : Icons.inventory_2_outlined)),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text([
        '${formatQuantity(item.quantity)} ${item.unit}',
        if (item.isLowStock) 'low stock',
        if (expiry != null) expired ? 'expired' : 'expires ${expiry.day}/${expiry.month}',
        if (item.note.isNotEmpty) item.note,
      ].join(' / ')),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(tooltip: 'Edit ${item.name}', onPressed: pantry.busy ? null : () => editPantryItem(context, item: item), icon: const Icon(Icons.edit_outlined)),
        IconButton(tooltip: 'Remove ${item.name}', onPressed: pantry.busy ? null : () async {
          if (!await confirmAction(context, title: 'Remove ${item.name}?', message: 'This only removes it from your pantry. Recipes and groceries stay unchanged.', confirmLabel: 'Remove')) return;
          final ok = await pantry.remove(item.id);
          if (context.mounted && !ok) showMessage(context, pantry.errorMessage ?? 'Could not remove the pantry item.');
        }, icon: const Icon(Icons.delete_outline_rounded)),
      ]),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.result});
  final PantryMatchResult result;

  String _statusLabel(PantryMatchStatus status) => switch (status) {
    PantryMatchStatus.canMakeNow => 'Can make now',
    PantryMatchStatus.almostReady => 'Almost ready',
    PantryMatchStatus.missingSome => 'Missing some',
    PantryMatchStatus.notReady => 'Needs a shop',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final missing = result.missing;
    return SurfaceCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(width: 108, height: 105, child: RecipeImage(recipe: result.recipe))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(result.recipe.title, style: Theme.of(context).textTheme.titleMedium)),
          Chip(label: Text('${result.matchPercentage.round()}%'))]),
        Text(_statusLabel(result.status), style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary)),
        const SizedBox(height: 5),
        Text(missing.isEmpty ? 'Everything measurable is already in your pantry.'
          : 'Missing: ${missing.take(3).map((row) => row.ingredient.name).join(', ')}${missing.length > 3 ? ' +${missing.length - 3} more' : ''}',
          maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 8, children: [
          TextButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: result.recipe),
            icon: const Icon(Icons.restaurant_menu_rounded), label: const Text('View recipe')),
          if (missing.isNotEmpty) OutlinedButton.icon(onPressed: context.watch<GroceryProvider>().busy ? null : () => _addMissing(context),
            icon: const Icon(Icons.shopping_bag_outlined), label: const Text('Add missing to groceries')),
        ]),
      ])),
    ]));
  }

  Future<void> _addMissing(BuildContext context) async {
    final grocery = context.read<GroceryProvider>();
    final ingredients = <Ingredient>[];
    for (final row in result.missing) {
      final required = row.requiredQuantity ?? 0;
      final available = row.availableQuantity ?? 0;
      final deficit = required - available;
      if (deficit <= 0) continue;
      ingredients.add(Ingredient(id: row.ingredient.id, name: row.ingredient.name,
        quantity: deficit, unit: row.unit, note: row.ingredient.note));
    }
    if (ingredients.isEmpty) return;
    final ok = await grocery.addIngredients('Missing for ${result.recipe.title}', ingredients,
      sourceId: 'pantry_${result.recipe.id}_missing');
    if (!context.mounted) return;
    showMessage(context, ok ? 'Missing ingredients added to groceries.' : grocery.errorMessage ?? 'Could not update groceries.');
  }
}
