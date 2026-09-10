import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/common.dart';
import '../../models/grocery_source.dart';
import '../providers/grocery_provider.dart';
Future<void> editGroceryItem(BuildContext context, {GrocerySource? source}) => showDialog<void>(
  context: context, builder: (_) => _GroceryItemDialog(source: source));
class _GroceryItemDialog extends StatefulWidget {
  const _GroceryItemDialog({this.source});
  final GrocerySource? source;
  @override
  State<_GroceryItemDialog> createState() => _GroceryItemDialogState();
}
class _GroceryItemDialogState extends State<_GroceryItemDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _quantity;
  late String _unit;
  static const _units = ['pcs', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup'];
  @override
  void initState() {
    super.initState();
    final ingredient = widget.source?.ingredients.first;
    _name = TextEditingController(text: ingredient?.name ?? '');
    _quantity = TextEditingController(text: formatQuantity(ingredient?.quantity ?? 1));
    _unit = _units.contains(ingredient?.unit) ? ingredient!.unit : 'pcs';
  }
  @override
  void dispose() { _name.dispose(); _quantity.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<GroceryProvider>();
    return AlertDialog(title: Text(widget.source == null ? 'Add something to your list' : 'Edit grocery contribution'),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Form(key: _form, child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          ErrorNotice(grocery.errorMessage), TextFormField(controller: _name, maxLength: 80,
            validator: (value) => (value ?? '').trim().isEmpty ? 'Enter an item name.' : null,
            decoration: const InputDecoration(labelText: 'Item name', hintText: 'For example, Rice')),
          const SizedBox(height: 16), TextFormField(controller: _quantity, validator: InputValidators.quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantity')),
          const SizedBox(height: 16), DropdownButtonFormField<String>(initialValue: _unit,
            decoration: const InputDecoration(labelText: 'Unit'), items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
            onChanged: (value) { if (value != null) setState(() => _unit = value); }),
          const SizedBox(height: 14), const Text('Matching names and compatible units combine automatically.'),
        ])))), actions: [TextButton(onPressed: grocery.busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(label: 'Save item', icon: Icons.check_rounded, loading: grocery.busy, onPressed: () async {
          if (!_form.currentState!.validate()) return;
          final ok = await grocery.saveManual(_name.text, double.parse(_quantity.text.trim()), _unit, sourceId: widget.source?.id);
          if (context.mounted && ok) Navigator.pop(context);
        })]);
  }
}
