class RecipeCategory {
  const RecipeCategory({required this.id, required this.name});
  final String id;
  final String name;
  factory RecipeCategory.fromJson(Map<String, dynamic> json) => RecipeCategory(id: json['id'] as String, name: json['name'] as String);
}
