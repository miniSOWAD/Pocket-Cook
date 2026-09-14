import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/recipe.dart';
import '../models/recipe_category.dart';
import 'recipe_repository.dart';

/// Reads the public cookbook from Firestore while keeping the current bundled
/// Pocket Cook catalog as a baseline.
///
/// Older Firebase projects may still contain tutorial-era `system` recipes.
/// Those stale system IDs are ignored. Current bundled IDs can be overridden by
/// Firestore after they are seeded, while Admin/Cook-created recipes are always
/// added to the catalog.
class FirestoreRecipeRepository implements RecipeRepository {
  FirestoreRecipeRepository(this.firestore, {AssetBundle? bundle})
      : bundle = bundle ?? rootBundle;

  final FirebaseFirestore firestore;
  final AssetBundle bundle;

  Future<List<Recipe>> _bundledRecipes() async {
    final data = jsonDecode(
      await bundle.loadString('assets/data/recipes.json'),
    ) as List;
    return data
        .map((item) => Recipe.fromJson(Map<String, dynamic>.from(item as Map)))
        .where((recipe) => recipe.isPublished)
        .toList();
  }

  Future<List<RecipeCategory>> _bundledCategories() async {
    final data = jsonDecode(
      await bundle.loadString('assets/data/categories.json'),
    ) as List;
    return data
        .map(
          (item) => RecipeCategory.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Stream<List<Recipe>> watchRecipes() async* {
    final bundled = await _bundledRecipes();
    final bundledById = <String, Recipe>{
      for (final recipe in bundled) recipe.id: recipe,
    };

    await for (final snapshot in firestore
        .collection('recipes')
        .where('isPublished', isEqualTo: true)
        .snapshots()) {
      final merged = <String, Recipe>{...bundledById};

      for (final doc in snapshot.docs) {
        final recipe = Recipe.fromJson({...doc.data(), 'id': doc.id});
        final currentSystemRecipe = bundledById.containsKey(recipe.id);
        if (recipe.createdByUid == 'system' && !currentSystemRecipe) {
          // Ignore stale system recipes from an older seed.
          continue;
        }
        // Current system IDs override their bundled copy when seeded. Recipes
        // created by Admins/Cooks are appended to the public cookbook.
        merged[recipe.id] = recipe;
      }

      final recipes = merged.values.toList()
        ..sort((a, b) {
          if (a.featured != b.featured) return a.featured ? -1 : 1;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
      yield recipes;
    }
  }

  @override
  Stream<List<RecipeCategory>> watchCategories() async* {
    final bundled = await _bundledCategories();
    await for (final snapshot in firestore.collection('categories').snapshots()) {
      final merged = <String, RecipeCategory>{
        for (final category in bundled) category.id: category,
      };
      for (final doc in snapshot.docs) {
        final category = RecipeCategory.fromJson({...doc.data(), 'id': doc.id});
        merged[category.id] = category;
      }
      yield merged.values.toList();
    }
  }
}
