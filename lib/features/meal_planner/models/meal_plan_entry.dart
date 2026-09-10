import '../../../core/utils/date_formatter.dart';
enum MealSlot { breakfast, lunch, dinner, snack }
extension MealSlotLabel on MealSlot {
  String get label => '${name[0].toUpperCase()}${name.substring(1)}';
}
class MealPlanEntry {
  const MealPlanEntry({required this.date, required this.slot, required this.recipeId,
      required this.recipeTitle, required this.servings});
  final DateTime date;
  final MealSlot slot;
  final String recipeId, recipeTitle;
  final int servings;
  String get id => '${dateKey(date)}_${slot.name}';
  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => MealPlanEntry(
    date: parseDateKey(json['date'] as String), slot: MealSlot.values.byName(json['slot'] as String),
    recipeId: json['recipeId'] as String, recipeTitle: json['recipeTitle'] as String,
    servings: (json['servings'] as num).toInt());
  Map<String, dynamic> toJson() => {'date': dateKey(date), 'slot': slot.name,
    'recipeId': recipeId, 'recipeTitle': recipeTitle, 'servings': servings,
    'updatedAt': DateTime.now().millisecondsSinceEpoch};
}
