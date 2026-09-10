import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../models/recipe_filter.dart';
import '../providers/recipe_catalog_provider.dart';
import '../providers/recipe_search_provider.dart';
import '../widgets/recipe_grid.dart';
class RecipeSearchScreen extends StatelessWidget {
  const RecipeSearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final search = context.watch<RecipeSearchProvider>();
    final catalog = context.watch<RecipeCatalogProvider>();
    final results = search.results;
    return Scaffold(appBar: AppBar(title: const Text('Explore recipes')), body: SafeArea(child: FeaturePage(
      title: 'Find your next favorite.', subtitle: 'Search titles, ingredients, and recipe tags.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(onChanged: search.setQuery, decoration: const InputDecoration(
          hintText: 'Try chickpeas, pasta, or breakfast', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 18),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          ChoiceChip(label: const Text('All recipes'), selected: search.categoryId == null, onSelected: (_) => search.setCategory(null)),
          for (final category in catalog.categories) Padding(padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(label: Text(category.name), selected: search.categoryId == category.id,
              onSelected: (_) => search.setCategory(category.id))),
        ])),
        const SizedBox(height: 12), Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          FilterChip(label: const Text('Vegetarian'), selected: search.vegetarianOnly, onSelected: search.setVegetarian,
            avatar: const Icon(Icons.eco_outlined, size: 17)),
          FilterChip(label: const Text('30 min or less'), selected: search.quickOnly, onSelected: search.setQuick,
            avatar: const Icon(Icons.schedule_rounded, size: 17)),
          DropdownButton<RecipeSort>(value: search.sort, underline: const SizedBox.shrink(),
            items: const [DropdownMenuItem(value: RecipeSort.recommended, child: Text('Recommended')),
              DropdownMenuItem(value: RecipeSort.quickest, child: Text('Quickest first')),
              DropdownMenuItem(value: RecipeSort.alphabetical, child: Text('A to Z'))],
            onChanged: (value) { if (value != null) search.setSort(value); }),
        ]),
        const SizedBox(height: 24), ErrorNotice(catalog.errorMessage, onRetry: catalog.load),
        if (catalog.loading) const LoadingView()
        else if (results.isEmpty) const EmptyStateView(icon: Icons.search_off_rounded,
          title: 'Nothing in the cookbook just yet', message: 'Try a different ingredient or remove a filter.')
        else ...[
          SectionHeading('${results.length} recipes to explore'), RecipeGrid(recipes: search.visibleResults),
          if (search.visibleCount < results.length) Padding(padding: const EdgeInsets.only(top: 24),
            child: Center(child: OutlinedButton(onPressed: search.showMore, child: const Text('Show more recipes')))),
        ],
      ]))));
  }
}
