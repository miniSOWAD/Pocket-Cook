class GroceryItem {
  const GroceryItem({required this.key, required this.name, required this.quantity,
    required this.unit, required this.sourceIds, required this.checked});
  final String key, name, unit;
  final double? quantity;
  final Set<String> sourceIds;
  final bool checked;
}
