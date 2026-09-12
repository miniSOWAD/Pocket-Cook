class PantryItem {
  const PantryItem({
    required this.id,
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.lowStockThreshold,
    this.expiryDate,
    this.note = '',
    required this.updatedAt,
  });

  final String id;
  final String ingredientId;
  final String name;
  final double quantity;
  final String unit;
  final double? lowStockThreshold;
  final DateTime? expiryDate;
  final String note;
  final int updatedAt;

  bool get isLowStock => lowStockThreshold != null && quantity <= lowStockThreshold!;

  factory PantryItem.fromJson(String id, Map<String, dynamic> json) {
    final quantity = (json['quantity'] as num?)?.toDouble();
    final threshold = (json['lowStockThreshold'] as num?)?.toDouble();
    final expiryRaw = json['expiryDate'];
    DateTime? expiry;
    if (expiryRaw is String && expiryRaw.isNotEmpty) expiry = DateTime.tryParse(expiryRaw);
    final result = PantryItem(
      id: id,
      ingredientId: json['ingredientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: quantity ?? -1,
      unit: json['unit'] as String? ?? '',
      lowStockThreshold: threshold,
      expiryDate: expiry,
      note: json['note'] as String? ?? '',
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? -1,
    );
    if (result.id.isEmpty || result.id.length > 120 ||
        result.ingredientId.isEmpty || result.ingredientId.length > 80 ||
        result.name.trim().isEmpty || result.name.length > 120 ||
        result.quantity < 0 || !result.quantity.isFinite ||
        result.unit.isEmpty || result.unit.length > 16 ||
        (result.lowStockThreshold != null &&
            (!result.lowStockThreshold!.isFinite || result.lowStockThreshold! < 0)) ||
        result.note.length > 240 || result.updatedAt < 0) {
      throw const FormatException('Invalid pantry item record.');
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'lowStockThreshold': lowStockThreshold,
        'expiryDate': expiryDate == null
            ? null
            : '${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}',
        'note': note,
        'updatedAt': updatedAt,
      };
}
