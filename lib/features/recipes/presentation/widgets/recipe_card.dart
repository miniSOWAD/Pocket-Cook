import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import 'recipe_image.dart';
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap,
    required this.isFavorite, this.onFavoritePressed});
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Stack(fit: StackFit.expand, children: [
        RecipeImage(recipe: recipe),
        Positioned(top: 10, right: 10, child: Material(color: Theme.of(context).colorScheme.surface,
          shape: const CircleBorder(), child: IconButton(
            tooltip: isFavorite ? 'Remove ${recipe.title} from favorites' : 'Save ${recipe.title}',
            onPressed: onFavoritePressed,
            icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Theme.of(context).colorScheme.secondary : null, size: 21)))),
        if (recipe.vegetarian) Positioned(left: 10, bottom: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFFF4F9EB), borderRadius: BorderRadius.circular(9)),
          child: const Text('VEGETARIAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
            letterSpacing: 0.8, color: Color(0xFF285B43))))),
      ])),
      Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 48.0 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble(), child: Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(height: 8),
        Row(children: [Icon(Icons.schedule_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5), Expanded(child: Text('${recipe.totalMinutes} min  /  ${recipe.difficulty}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall))]),
      ])),
    ])));
}
