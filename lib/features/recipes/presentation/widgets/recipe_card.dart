import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/recipe.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.isFavorite,
    this.onFavoritePressed,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepCyan.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(recipe: recipe),
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                          padding: EdgeInsets.zero,
                          tooltip: isFavorite
                              ? 'Remove ${recipe.title} from favorites'
                              : 'Save ${recipe.title}',
                          onPressed: onFavoritePressed,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite ? AppTheme.lightOrange : scheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (recipe.vegetarian)
                      Positioned(
                        left: 11,
                        bottom: 11,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco_rounded, size: 12, color: scheme.primary),
                              const SizedBox(width: 5),
                              Text(
                                'VEG',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.65,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.18,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cook: ${recipe.cookName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        _Meta(icon: Icons.schedule_rounded, text: '${recipe.totalMinutes} min'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.orangeWash.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF70410B),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: scheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}
