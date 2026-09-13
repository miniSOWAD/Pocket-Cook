import 'package:cloud_firestore/cloud_firestore.dart';
import '../../recipes/models/recipe.dart';
import 'recipe_management_repository.dart';

class FirestoreRecipeManagementRepository implements RecipeManagementRepository {
  FirestoreRecipeManagementRepository(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Stream<List<Recipe>> watchAllRecipes() => firestore.collection('recipes').snapshots().map((snapshot) {
        final recipes = snapshot.docs
            .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
        recipes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return recipes;
      });

  @override
  Future<void> saveRecipe(Recipe recipe) => firestore.doc('recipes/${recipe.id}').set(recipe.toJson());

  @override
  Future<void> deleteRecipe(String recipeId) => firestore.doc('recipes/$recipeId').delete();
}
