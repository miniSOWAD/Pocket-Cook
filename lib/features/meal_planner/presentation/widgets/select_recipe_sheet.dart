import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/models/recipe_filter.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../recipes/presentation/widgets/recipe_image.dart';
Future<Recipe?> selectRecipe(BuildContext context) => showModalBottomSheet<Recipe>(
  context: context, isScrollControlled: true, useSafeArea: true,
  builder: (_) => const _RecipePicker());
class _RecipePicker extends StatefulWidget {
  const _RecipePicker();
  @override
  State<_RecipePicker> createState() => _RecipePickerState();
}
class _RecipePickerState extends State<_RecipePicker> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<RecipeCatalogProvider>();
    final results = RecipeFilter(query: _query).apply(catalog.recipes);
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.72, child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 12), child: Column(children: [
          Row(children: [Expanded(child: Text('Choose a recipe', style: Theme.of(context).textTheme.titleLarge)),
            IconButton(tooltip: 'Close recipe picker', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
          const SizedBox(height: 12), TextField(onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(hintText: 'Search your cookbook', prefixIcon: Icon(Icons.search_rounded))),
          const SizedBox(height: 14), ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
          Expanded(child: catalog.loading ? const LoadingView() : results.isEmpty
            ? const EmptyStateView(title: 'No matching recipes', message: 'Try another search.')
            : ListView.separated(itemCount: results.length, separatorBuilder: (_, index) => const Divider(),
              itemBuilder: (context, index) {
                final recipe = results[index];
                return ListTile(contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 60, height: 60, child: RecipeImage(recipe: recipe))),
                  title: Text(recipe.title), subtitle: Text('${recipe.totalMinutes} min / ${recipe.baseServings} servings'),
                  trailing: const Icon(Icons.add_circle_outline_rounded), onTap: () => Navigator.pop(context, recipe));
              })),
        ]))));
  }
}
