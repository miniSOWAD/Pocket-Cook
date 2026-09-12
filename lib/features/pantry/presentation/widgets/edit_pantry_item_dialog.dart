import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../../recipes/models/ingredient.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../logic/pantry_units.dart';
import '../../models/pantry_item.dart';
import '../providers/pantry_provider.dart';

Future<void> editPantryItem(BuildContext context, {PantryItem? item}) =>
    showDialog<void>(context: context, builder: (_) => _PantryItemDialog(item: item));

class _PantryItemDialog extends StatefulWidget {
  const _PantryItemDialog({this.item});
  final PantryItem? item;
  @override
  State<_PantryItemDialog> createState() => _PantryItemDialogState();
}

class _PantryItemDialogState extends State<_PantryItemDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _quantity, _threshold, _note;
  late String _ingredientId, _unit;
  DateTime? _expiry;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _ingredientId = item?.ingredientId ?? '';
    _name = TextEditingController(text: item?.name ?? '');
    _quantity = TextEditingController(text: formatQuantity(item?.quantity ?? 1));
    _threshold = TextEditingController(text: item?.lowStockThreshold == null ? '' : formatQuantity(item!.lowStockThreshold));
    _note = TextEditingController(text: item?.note ?? '');
    _unit = PantryUnits.supported.contains(item?.unit) ? item!.unit : 'pcs';
    _expiry = item?.expiryDate;
  }

  @override
  void dispose() {
    _name.dispose(); _quantity.dispose(); _threshold.dispose(); _note.dispose();
    super.dispose();
  }

  String _slug(String value) {
    final slug = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? 'pantry-item' : slug;
  }

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final catalog = context.read<RecipeCatalogProvider>();
    final known = <String, Ingredient>{};
    for (final recipe in catalog.recipes) {
      for (final ingredient in recipe.ingredients) {
        known.putIfAbsent(ingredient.id, () => ingredient);
      }
    }
    final sorted = known.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    final selectedKnown = known.containsKey(_ingredientId) ? _ingredientId : '__custom__';

    return AlertDialog(
      title: Text(widget.item == null ? 'Add to your pantry' : 'Edit pantry item'),
      content: SizedBox(width: 440, child: SingleChildScrollView(child: Form(key: _form, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          ErrorNotice(pantry.errorMessage),
          DropdownButtonFormField<String>(
            initialValue: widget.item == null ? null : selectedKnown,
            decoration: const InputDecoration(labelText: 'Match to recipe ingredient', helperText: 'Matching an ingredient gives better recipe suggestions.'),
            items: [
              for (final ingredient in sorted) DropdownMenuItem(value: ingredient.id, child: Text(ingredient.name)),
              const DropdownMenuItem(value: '__custom__', child: Text('Other ingredient')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                if (value == '__custom__') {
                  _ingredientId = _slug(_name.text);
                } else {
                  final ingredient = known[value]!;
                  _ingredientId = ingredient.id;
                  _name.text = ingredient.name;
                  if (PantryUnits.supported.contains(ingredient.unit)) _unit = ingredient.unit;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _name, maxLength: 120,
            validator: (value) => (value ?? '').trim().isEmpty ? 'Enter an ingredient name.' : null,
            onChanged: (value) { if (!known.containsKey(_ingredientId)) _ingredientId = _slug(value); },
            decoration: const InputDecoration(labelText: 'Ingredient name', hintText: 'For example, Rice')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextFormField(controller: _quantity, validator: InputValidators.quantity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity'))),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(initialValue: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              items: PantryUnits.supported.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
              onChanged: (value) { if (value != null) setState(() => _unit = value); })),
          ]),
          const SizedBox(height: 16),
          TextFormField(controller: _threshold,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return null;
              final parsed = double.tryParse(value!.trim());
              if (parsed == null || !parsed.isFinite || parsed < 0) return 'Enter 0 or a positive number.';
              return null;
            },
            decoration: const InputDecoration(labelText: 'Low-stock alert at', helperText: 'Optional. Uses the same unit as the quantity.')),
          const SizedBox(height: 16),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_outlined),
            title: Text(_expiry == null ? 'No expiry date' : 'Expires ${_expiry!.day}/${_expiry!.month}/${_expiry!.year}'),
            subtitle: const Text('Optional'),
            trailing: Wrap(children: [
              if (_expiry != null) IconButton(tooltip: 'Clear expiry', onPressed: () => setState(() => _expiry = null), icon: const Icon(Icons.close_rounded)),
              IconButton(tooltip: 'Choose expiry date', onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(context: context, initialDate: _expiry ?? now,
                  firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 10));
                if (picked != null && mounted) setState(() => _expiry = picked);
              }, icon: const Icon(Icons.calendar_month_outlined)),
            ])),
          const SizedBox(height: 8),
          TextFormField(controller: _note, maxLength: 240, maxLines: 2,
            decoration: const InputDecoration(labelText: 'Note', hintText: 'Brand, storage place, or anything useful')),
        ])))),
      actions: [
        TextButton(onPressed: pantry.busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(label: 'Save item', icon: Icons.check_rounded, loading: pantry.busy, onPressed: () async {
          if (!_form.currentState!.validate()) return;
          final name = _name.text.trim();
          final id = known.containsKey(_ingredientId) ? _ingredientId : _slug(name);
          final thresholdText = _threshold.text.trim();
          final ok = await pantry.save(id: widget.item?.id, ingredientId: id, name: name,
            quantity: double.parse(_quantity.text.trim()), unit: _unit,
            lowStockThreshold: thresholdText.isEmpty ? null : double.parse(thresholdText),
            expiryDate: _expiry, note: _note.text);
          if (context.mounted && ok) Navigator.pop(context);
        }),
      ],
    );
  }
}
