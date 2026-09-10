String formatQuantity(double? quantity) {
  if (quantity == null) return 'to taste';
  if ((quantity - quantity.round()).abs() < 0.000001) return quantity.round().toString();
  return quantity.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
