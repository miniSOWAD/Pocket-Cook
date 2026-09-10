import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../models/recipe_category.dart';
import 'recipe_repository.dart';
class FirestoreRecipeRepository implements RecipeRepository {
  FirestoreRecipeRepository(this.firestore);
  final FirebaseFirestore firestore;
  // Small-catalog implementation: all published records are watched. Search
  // and "Show more" happen locally, not as server-side full-text pagination.
  @override
  Stream<List<Recipe>> watchRecipes() => firestore.collection('recipes')
    .where('isPublished', isEqualTo: true).snapshots().map((snapshot) => snapshot.docs
    .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id})).toList());
  @override
  Stream<List<RecipeCategory>> watchCategories() => firestore.collection('categories')
    .snapshots().map((snapshot) => snapshot.docs
    .map((doc) => RecipeCategory.fromJson({...doc.data(), 'id': doc.id})).toList());
}
