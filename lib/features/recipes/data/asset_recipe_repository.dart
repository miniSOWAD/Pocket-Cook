import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe.dart';
import '../models/recipe_category.dart';
import 'recipe_repository.dart';
class AssetRecipeRepository implements RecipeRepository {
  AssetRecipeRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;
  final AssetBundle bundle;
  @override
  Stream<List<Recipe>> watchRecipes() async* {
    final data = jsonDecode(await bundle.loadString('assets/data/recipes.json')) as List;
    yield data.map((item) => Recipe.fromJson(Map<String, dynamic>.from(item as Map)))
      .where((recipe) => recipe.isPublished).toList();
  }
  @override
  Stream<List<RecipeCategory>> watchCategories() async* {
    final data = jsonDecode(await bundle.loadString('assets/data/categories.json')) as List;
    yield data.map((item) => RecipeCategory.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }
}
