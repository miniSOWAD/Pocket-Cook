import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/presentation/providers/recipe_catalog_provider.dart';
import '../../../requests/models/recipe_request.dart';
import '../../../requests/presentation/providers/staff_requests_provider.dart';
import '../providers/recipe_management_provider.dart';
import '../widgets/recipe_editor_dialog.dart';

class ManageRecipesScreen extends StatelessWidget {
  const ManageRecipesScreen({super.key});

  Future<void> _edit(
    BuildContext context, {
    Recipe? recipe,
    RecipeRequest? request,
  }) async {
    final account = context.read<AccountProvider>().account;
    if (account == null || !account.canManageRecipes) {
      showMessage(context, 'Only active Cooks and Admins can manage recipes.');
      return;
    }
    final categories = context.read<RecipeCatalogProvider>().categories;
    if (categories.isEmpty) {
      showMessage(context, 'Recipe categories are still loading.');
      return;
    }
    final result = await showRecipeEditor(
      context,
      account: account,
      categories: categories,
      recipe: recipe,
      requestedTitle: request?.title,
      requestedDetails: request?.details,
      requestId: request?.id,
    );
    if (result == null || !context.mounted) return;
    final manager = context.read<RecipeManagementProvider>();
    final ok = await manager.save(result.recipe);
    if (!context.mounted) return;
    if (!ok) {
      showMessage(context, manager.errorMessage ?? 'Could not save the recipe.');
      return;
    }
    if (result.fulfilledRequestId != null) {
      await context.read<StaffRequestsProvider>().setRecipeStatus(
            result.fulfilledRequestId!,
            'fulfilled',
            fulfilledRecipeId: result.recipe.id,
          );
    }
    if (context.mounted) showMessage(context, recipe == null ? 'Recipe added.' : 'Recipe updated.');
  }

  Future<void> _delete(BuildContext context, Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('Delete “${recipe.title}”? This removes it from the public cookbook too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final manager = context.read<RecipeManagementProvider>();
    final ok = await manager.delete(recipe.id);
    if (context.mounted) showMessage(context, ok ? 'Recipe deleted.' : manager.errorMessage ?? 'Could not delete recipe.');
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<RecipeManagementProvider>();
    final requests = context.watch<StaffRequestsProvider>();
    final account = context.watch<AccountProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage recipes')),
      body: SafeArea(
        child: FeaturePage(
          title: 'Care for the cookbook.',
          subtitle: 'Add, update, publish, or remove recipes. Every recipe keeps the name of the Cook who created it.',
          eyebrow: account.isAdmin ? 'Admin kitchen' : 'Cook kitchen',
          trailing: FilledButton.icon(
            onPressed: manager.busy ? null : () => _edit(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add recipe'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorNotice(manager.errorMessage),
              ErrorNotice(requests.errorMessage),
              const SectionHeading(
                'Requested recipes',
                subtitle: 'Use a request to prefill a new recipe, then edit the details before publishing.',
              ),
              if (requests.pendingRecipeRequests.isEmpty)
                const InfoBanner('No pending recipe requests right now.', icon: Icons.inbox_outlined)
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: requests.pendingRecipeRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final request = requests.pendingRecipeRequests[index];
                      return SizedBox(
                        width: 310,
                        child: SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(request.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('From ${request.requesterName}', style: Theme.of(context).textTheme.bodySmall),
                            const Spacer(),
                            FilledButton.tonalIcon(
                              onPressed: manager.busy ? null : () => _edit(context, request: request),
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Create from request'),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),
              SectionHeading('All recipes', subtitle: '${manager.recipes.length} recipes'),
              if (manager.loading)
                const LoadingView()
              else if (manager.recipes.isEmpty)
                const EmptyStateView(title: 'No recipes found', message: 'Add the first recipe to this kitchen.')
              else
                for (final recipe in manager.recipes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(recipe.title, style: Theme.of(context).textTheme.titleMedium)),
                            Chip(label: Text(recipe.isPublished ? 'PUBLISHED' : 'DRAFT')),
                          ]),
                          const SizedBox(height: 5),
                          Text('Cook: ${recipe.cookName}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${recipe.categoryId} · ${recipe.totalMinutes} min · ${recipe.difficulty}', style: Theme.of(context).textTheme.bodySmall),
                        ]);
                        final actions = Wrap(spacing: 8, children: [
                          OutlinedButton.icon(
                            onPressed: manager.busy ? null : () => _edit(context, recipe: recipe),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          IconButton(
                            tooltip: 'Delete recipe',
                            onPressed: manager.busy ? null : () => _delete(context, recipe),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ]);
                        if (constraints.maxWidth < 650) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [details, const SizedBox(height: 12), actions]);
                        }
                        return Row(children: [Expanded(child: details), const SizedBox(width: 12), actions]);
                      }),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
