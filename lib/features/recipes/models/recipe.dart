import 'ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.baseServings,
    required this.ingredients,
    required this.steps,
    required this.imageAsset,
    this.imageUrl = '',
    this.difficulty = 'Easy',
    this.vegetarian = false,
    this.featured = false,
    this.tags = const [],
    this.isPublished = true,
    this.createdByUid = 'system',
    this.cookName = "Liza's Kitchen",
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String difficulty;
  final String imageAsset;
  final String imageUrl;
  final int prepMinutes;
  final int cookMinutes;
  final int baseServings;
  final bool vegetarian;
  final bool featured;
  final bool isPublished;
  final List<String> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final String createdByUid;
  final String cookName;
  final int createdAt;
  final int updatedAt;

  int get totalMinutes => prepMinutes + cookMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final result = Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      prepMinutes: (json['prepMinutes'] as num).toInt(),
      cookMinutes: (json['cookMinutes'] as num).toInt(),
      baseServings: (json['baseServings'] as num).toInt(),
      ingredients: (json['ingredients'] as List)
          .map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      steps: (json['steps'] as List)
          .map((item) => RecipeStep.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      imageAsset: json['imageAsset'] as String? ?? 'assets/images/recipes/green-goddess-bowl.png',
      imageUrl: json['imageUrl'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      vegetarian: json['vegetarian'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      isPublished: json['isPublished'] as bool? ?? true,
      tags: List<String>.from(json['tags'] as List? ?? const []),
      createdByUid: json['createdByUid'] as String? ?? 'system',
      cookName: (json['cookName'] as String?)?.trim().isNotEmpty == true
          ? (json['cookName'] as String).trim()
          : "Liza's Kitchen",
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );
    if (result.id.isEmpty ||
        result.title.trim().isEmpty ||
        result.baseServings < 1 ||
        result.baseServings > 12 ||
        result.prepMinutes < 0 ||
        result.cookMinutes < 0 ||
        result.ingredients.isEmpty ||
        result.steps.isEmpty ||
        json['baseServings'] is! int ||
        json['prepMinutes'] is! int ||
        json['cookMinutes'] is! int) {
      throw const FormatException('Invalid recipe record.');
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'prepMinutes': prepMinutes,
        'cookMinutes': cookMinutes,
        'baseServings': baseServings,
        'ingredients': ingredients.map((item) => item.toJson()).toList(),
        'steps': steps.map((item) => item.toJson()).toList(),
        'imageAsset': imageAsset,
        'imageUrl': imageUrl,
        'difficulty': difficulty,
        'vegetarian': vegetarian,
        'featured': featured,
        'isPublished': isPublished,
        'tags': tags,
        'createdByUid': createdByUid,
        'cookName': cookName,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    int? prepMinutes,
    int? cookMinutes,
    int? baseServings,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    String? imageAsset,
    String? imageUrl,
    String? difficulty,
    bool? vegetarian,
    bool? featured,
    bool? isPublished,
    List<String>? tags,
    String? createdByUid,
    String? cookName,
    int? createdAt,
    int? updatedAt,
  }) =>
      Recipe(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        prepMinutes: prepMinutes ?? this.prepMinutes,
        cookMinutes: cookMinutes ?? this.cookMinutes,
        baseServings: baseServings ?? this.baseServings,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        imageAsset: imageAsset ?? this.imageAsset,
        imageUrl: imageUrl ?? this.imageUrl,
        difficulty: difficulty ?? this.difficulty,
        vegetarian: vegetarian ?? this.vegetarian,
        featured: featured ?? this.featured,
        isPublished: isPublished ?? this.isPublished,
        tags: tags ?? this.tags,
        createdByUid: createdByUid ?? this.createdByUid,
        cookName: cookName ?? this.cookName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
