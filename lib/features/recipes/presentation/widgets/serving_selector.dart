import 'package:flutter/material.dart';
class ServingSelector extends StatelessWidget {
  const ServingSelector({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton.outlined(tooltip: 'Fewer servings', onPressed: value > 1 ? () => onChanged(value - 1) : null,
      icon: const Icon(Icons.remove_rounded, size: 19)),
    SizedBox(width: 42, child: Text('$value', textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium)),
    IconButton.outlined(tooltip: 'More servings', onPressed: value < 12 ? () => onChanged(value + 1) : null,
      icon: const Icon(Icons.add_rounded, size: 19)),
  ]);
}
