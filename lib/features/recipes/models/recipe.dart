import 'ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  const Recipe({required this.id, required this.title, required this.description,
    required this.categoryId, required this.prepMinutes, required this.cookMinutes,
    required this.baseServings, required this.ingredients, required this.steps,
    required this.imageAsset, this.imageUrl = '', this.difficulty = 'Easy',
    this.vegetarian = false, this.featured = false, this.tags = const [], this.isPublished = true});
  final String id, title, description, categoryId, difficulty, imageAsset, imageUrl;
  final int prepMinutes, cookMinutes, baseServings;
  final bool vegetarian, featured, isPublished;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  int get totalMinutes => prepMinutes + cookMinutes;
  factory Recipe.fromJson(Map<String, dynamic> json) {
    final result = Recipe(
    id: json['id'] as String, title: json['title'] as String,
    description: json['description'] as String, categoryId: json['categoryId'] as String,
    prepMinutes: (json['prepMinutes'] as num).toInt(), cookMinutes: (json['cookMinutes'] as num).toInt(),
    baseServings: (json['baseServings'] as num).toInt(),
    ingredients: (json['ingredients'] as List).map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
    steps: (json['steps'] as List).map((item) => RecipeStep.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
    imageAsset: json['imageAsset'] as String? ?? 'assets/images/recipes/green-goddess-bowl.png',
    imageUrl: json['imageUrl'] as String? ?? '', difficulty: json['difficulty'] as String? ?? 'Easy',
    vegetarian: json['vegetarian'] as bool? ?? false, featured: json['featured'] as bool? ?? false,
    isPublished: json['isPublished'] as bool? ?? true,
    tags: List<String>.from(json['tags'] as List? ?? const []),
    );
    if (result.id.isEmpty || result.title.trim().isEmpty ||
        result.baseServings < 1 || result.baseServings > 12 ||
        result.prepMinutes < 0 || result.cookMinutes < 0 ||
        result.ingredients.isEmpty || result.steps.isEmpty ||
        json['baseServings'] is! int || json['prepMinutes'] is! int || json['cookMinutes'] is! int) {
      throw const FormatException('Invalid recipe record.');
    }
    return result;
  }
}
