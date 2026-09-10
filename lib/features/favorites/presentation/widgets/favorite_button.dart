import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/auth_guard.dart';
import '../../../../core/widgets/common.dart';
import '../providers/favorites_provider.dart';
Future<void> toggleFavorite(BuildContext context, String recipeId) async {
  if (!await ensureSignedIn(context) || !context.mounted) return;
  final provider = context.read<FavoritesProvider>();
  final wasSaved = provider.contains(recipeId);
  final ok = await provider.toggle(recipeId);
  if (context.mounted) showMessage(context, ok ? (wasSaved ? 'Removed from favorites.' : 'Saved to your favorites.')
    : provider.errorMessage ?? 'Please try again.');
}
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.recipeId});
  final String recipeId;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritesProvider>();
    final saved = provider.contains(recipeId);
    return IconButton(tooltip: saved ? 'Remove from favorites' : 'Save recipe',
      onPressed: provider.busy ? null : () => toggleFavorite(context, recipeId),
      icon: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: saved ? Theme.of(context).colorScheme.secondary : null));
  }
}
