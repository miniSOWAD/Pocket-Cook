class Ingredient {
  const Ingredient({required this.id, required this.name, this.quantity, required this.unit, this.note = ''});
  final String id;
  final String name;
  final double? quantity;
  final String unit;
  final String note;
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    final result = Ingredient(
    id: json['id'] as String, name: json['name'] as String,
    quantity: (json['quantity'] as num?)?.toDouble(), unit: json['unit'] as String? ?? '',
    note: json['note'] as String? ?? '',
    );
    if (result.id.isEmpty || result.id.length > 80 ||
        result.name.trim().isEmpty || result.name.length > 120 ||
        result.unit.length > 16 || result.note.length > 240 ||
        (result.quantity != null && (!result.quantity!.isFinite || result.quantity! <= 0))) {
      throw const FormatException('Invalid ingredient record.');
    }
    return result;
  }
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'quantity': quantity, 'unit': unit, 'note': note};
  Ingredient withQuantity(double? value) => Ingredient(id: id, name: name, quantity: value, unit: unit, note: note);
}
