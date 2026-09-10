import 'package:flutter/material.dart';
import '../../models/recipe.dart';
class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.recipe, this.fit = BoxFit.cover});
  final Recipe recipe;
  final BoxFit fit;
  Widget _asset(BuildContext context) => Image.asset(recipe.imageAsset, fit: fit,
    width: double.infinity, height: double.infinity,
    errorBuilder: (_, error, stack) => ColoredBox(color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(child: Icon(Icons.restaurant_rounded, size: 60))));
  @override
  Widget build(BuildContext context) => Semantics(label: '${recipe.title} illustration', image: true,
    child: ExcludeSemantics(child: recipe.imageUrl.startsWith('https://')
      ? Image.network(recipe.imageUrl, fit: fit, width: double.infinity, height: double.infinity,
          errorBuilder: (_, error, stack) => _asset(context),
          loadingBuilder: (_, child, progress) => progress == null ? child : _asset(context))
      : _asset(context)));
}
