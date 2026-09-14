import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/recipe_image.dart';
import '../../logic/make_plate_matcher.dart';
import '../../models/available_ingredient.dart';
import '../../models/plate_recipe_match.dart';

class MakePlateScreen extends StatefulWidget {
  const MakePlateScreen({super.key});

  @override
  State<MakePlateScreen> createState() => _MakePlateScreenState();
}

class _MakePlateScreenState extends State<MakePlateScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _matcher = const MakePlateMatcher();
  final _items = <AvailableIngredient>[];
  String _unit = 'pcs';
  bool _searched = false;

  static const _units = ['pcs', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup'];
  static const _quick = ['Rice', 'Chicken', 'Egg', 'Potato', 'Onion', 'Tomato'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addItem({String? quickName}) {
    final name = (quickName ?? _nameController.text).trim();
    if (name.isEmpty) {
      showMessage(context, 'Type an ingredient first.');
      return;
    }

    double? amount;
    final amountText = quickName == null ? _amountController.text.trim() : '';
    if (amountText.isNotEmpty) {
      amount = double.tryParse(amountText.replaceAll(',', '.'));
      if (amount == null || amount <= 0) {
        showMessage(context, 'Amount must be a number greater than zero.');
        return;
      }
    }

    final duplicate = _items.indexWhere((item) => item.name.toLowerCase() == name.toLowerCase());
    final value = AvailableIngredient(name: name, quantity: amount, unit: amount == null ? '' : _unit);
    setState(() {
      if (duplicate >= 0) {
        _items[duplicate] = value;
      } else {
        _items.add(value);
      }
      _searched = false;
    });
    _nameController.clear();
    _amountController.clear();
  }

  void _removeItem(int index) => setState(() {
        _items.removeAt(index);
        _searched = false;
      });

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RecipeCatalogProvider>();
    final matches = _searched
        ? _matcher.match(recipes: catalog.recipes, available: _items)
        : const <PlateRecipeMatch>[];
    final ready = matches.where((match) => match.canMakeNow).toList();
    final close = matches.where((match) => !match.canMakeNow).toList();

    return FeaturePage(
      pageKey: 'make-ur-plate',
      eyebrow: 'Use what you have',
      title: 'Make ur plate',
      subtitle: 'Tell Pocket Cook what is in your kitchen. Amounts are optional — add them when you want more accurate matching.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IngredientComposer(
            nameController: _nameController,
            amountController: _amountController,
            unit: _unit,
            units: _units,
            quickItems: _quick,
            onUnitChanged: (value) => setState(() => _unit = value),
            onAdd: _addItem,
            onQuickAdd: (name) => _addItem(quickName: name),
          ),
          const SizedBox(height: 18),
          if (_items.isNotEmpty) ...[
            _AvailableList(items: _items, onRemove: _removeItem),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: catalog.loading
                    ? null
                    : () => setState(() => _searched = true),
                icon: const Icon(Icons.ramen_dining_rounded),
                label: Text(_searched ? 'Match again' : 'Find recipes I can make'),
              ),
            ),
          ] else
            const InfoBanner(
              'Start with two or three ingredients. For example: chicken, rice, onion — or add 500 g chicken if you know the amount.',
              icon: Icons.lightbulb_outline_rounded,
            ),
          const SizedBox(height: 32),
          if (_searched) ...[
            if (matches.isEmpty)
              const EmptyStateView(
                title: 'No useful matches yet',
                message: 'Add a few more ingredients and try again. Pocket Cook will rank recipes by how much of the recipe you already have.',
                icon: Icons.ramen_dining_rounded,
              )
            else ...[
              if (ready.isNotEmpty) ...[
                SectionHeading(
                  'Ready to cook',
                  subtitle: '${ready.length} recipe${ready.length == 1 ? '' : 's'} match the ingredients you listed.',
                ),
                for (final match in ready) ...[
                  _MatchCard(match: match),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 18),
              ],
              if (close.isNotEmpty) ...[
                const SectionHeading(
                  'Closest matches',
                  subtitle: 'You have part of what these recipes need. Missing items are shown below.',
                ),
                for (final match in close.take(8)) ...[
                  _MatchCard(match: match),
                  const SizedBox(height: 14),
                ],
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _IngredientComposer extends StatelessWidget {
  const _IngredientComposer({
    required this.nameController,
    required this.amountController,
    required this.unit,
    required this.units,
    required this.quickItems,
    required this.onUnitChanged,
    required this.onAdd,
    required this.onQuickAdd,
  });

  final TextEditingController nameController;
  final TextEditingController amountController;
  final String unit;
  final List<String> units;
  final List<String> quickItems;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onAdd;
  final ValueChanged<String> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.orangeWash,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.kitchen_rounded, color: Color(0xFFB25B00)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What do you have?', style: Theme.of(context).textTheme.titleLarge),
                    Text('Ingredient is required. Amount and unit are optional.', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 680;
              final name = TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ingredient',
                  hintText: 'e.g. chicken, rice, onion',
                  prefixIcon: Icon(Icons.restaurant_rounded),
                ),
                onSubmitted: (_) => onAdd(),
              );
              final amount = TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (optional)',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              );
              final unitPicker = DropdownButtonFormField<String>(
                initialValue: unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: [for (final item in units) DropdownMenuItem(value: item, child: Text(item))],
                onChanged: (value) {
                  if (value != null) onUnitChanged(value);
                },
              );
              if (narrow) {
                return Column(
                  children: [
                    name,
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: amount),
                        const SizedBox(width: 10),
                        SizedBox(width: 120, child: unitPicker),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: name),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: amount),
                  const SizedBox(width: 12),
                  SizedBox(width: 125, child: unitPicker),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add item'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No amount? That is okay — Pocket Cook will treat the ingredient as available.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Quick add', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in quickItems)
                ActionChip(
                  avatar: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: Text(item),
                  onPressed: () => onQuickAdd(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailableList extends StatelessWidget {
  const _AvailableList({required this.items, required this.onRemove});
  final List<AvailableIngredient> items;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        tint: AppTheme.skyMist,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('On your counter', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (var index = 0; index < items.length; index++)
                  InputChip(
                    avatar: const Icon(Icons.check_circle_rounded, size: 17),
                    label: Text('${items[index].name} · ${items[index].displayAmount}'),
                    onDeleted: () => onRemove(index),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});
  final PlateRecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final recipe = match.recipe;
    final ready = match.canMakeNow;
    final accent = ready ? scheme.primary : AppTheme.lightOrange;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.pushNamed(context, AppRoutes.recipe, arguments: recipe),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 560;
              final image = ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(width: narrow ? double.infinity : 150, height: 130, child: RecipeImage(recipe: recipe)),
              );
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          match.statusLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: ready ? scheme.primary : const Color(0xFFA15100),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Text('${match.matchedIngredients}/${match.requiredIngredients} ingredients covered', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(recipe.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text('${recipe.totalMinutes} min · ${recipe.difficulty} · Cook: ${recipe.cookName}', style: Theme.of(context).textTheme.bodySmall),
                  if (match.missingIngredients.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Text('Missing: ${match.missingIngredients.take(3).join(' • ')}${match.missingIngredients.length > 3 ? ' • +${match.missingIngredients.length - 3} more' : ''}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                  if (match.shortIngredients.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text('Need more: ${match.shortIngredients.take(2).join(' • ')}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFA15100))),
                  ],
                ],
              );
              if (narrow) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(height: 14), content]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [image, const SizedBox(width: 18), Expanded(child: content)]);
            },
          ),
        ),
      ),
    );
  }
}
