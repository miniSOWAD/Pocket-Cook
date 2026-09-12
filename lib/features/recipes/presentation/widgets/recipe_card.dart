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
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.dustyRose.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RecipeImage(recipe: recipe),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              AppTheme.cocoa.withValues(alpha: 0.11),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: scheme.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 0,
                        child: IconButton(
                          tooltip: isFavorite ? 'Remove ${recipe.title} from favorites' : 'Save ${recipe.title}',
                          onPressed: onFavoritePressed,
                          icon: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? AppTheme.dustyRose : scheme.primary,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                    if (recipe.vegetarian)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.offWhite.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco_rounded, size: 12, color: AppTheme.deepRose),
                              SizedBox(width: 5),
                              Text(
                                'VEGETARIAN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                  color: AppTheme.deepRose,
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
                padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48.0 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0).toDouble(),
                      child: Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _MiniMeta(icon: Icons.schedule_rounded, text: '${recipe.totalMinutes} min'),
                        const SizedBox(width: 10),
                        Container(width: 3, height: 3, decoration: BoxDecoration(color: scheme.outline, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recipe.difficulty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
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

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}
