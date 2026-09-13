import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../../requests/models/cook_application.dart';
import '../../../requests/models/recipe_request.dart';
import '../../../requests/presentation/providers/staff_requests_provider.dart';
import '../providers/admin_provider.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  Future<void> _reviewCook(BuildContext context, CookApplication application, bool approve) async {
    final admin = context.read<AdminProvider>();
    final ok = await admin.reviewCookApplication(application.uid, approve);
    if (!context.mounted) return;
    showMessage(
      context,
      ok ? (approve ? '${application.requesterName} is now a Cook.' : 'Cook request rejected.') : admin.errorMessage ?? 'Could not review the request.',
    );
  }

  Future<void> _setRecipeStatus(BuildContext context, RecipeRequest request, String status) async {
    final provider = context.read<StaffRequestsProvider>();
    final ok = await provider.setRecipeStatus(request.id, status);
    if (context.mounted) showMessage(context, ok ? 'Recipe request updated.' : provider.errorMessage ?? 'Could not update request.');
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<StaffRequestsProvider>();
    final admin = context.watch<AdminProvider>();
    final pendingCooks = requests.cookApplications.where((item) => item.isPending).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Cook requests')),
      body: SafeArea(
        child: FeaturePage(
          title: 'Requests waiting for you.',
          subtitle: 'Approve new cooks and review recipe wishes from visitors and the cooking team.',
          eyebrow: 'Admin review',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorNotice(requests.errorMessage),
              ErrorNotice(admin.errorMessage),
              SectionHeading('Wanna be Cook requests', subtitle: '${pendingCooks.length} pending'),
              if (pendingCooks.isEmpty)
                const InfoBanner('There are no pending Cook applications right now.', icon: Icons.check_circle_outline_rounded)
              else
                for (final application in pendingCooks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(application.requesterName, style: Theme.of(context).textTheme.titleMedium),
                        if (application.message.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(application.message),
                        ],
                        const SizedBox(height: 14),
                        Wrap(spacing: 10, runSpacing: 8, children: [
                          FilledButton.icon(
                            onPressed: admin.busy ? null : () => _reviewCook(context, application, true),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Accept as Cook'),
                          ),
                          OutlinedButton.icon(
                            onPressed: admin.busy ? null : () => _reviewCook(context, application, false),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Reject'),
                          ),
                        ]),
                      ]),
                    ),
                  ),
              const SizedBox(height: 30),
              SectionHeading('Recipe requests', subtitle: '${requests.recipeRequests.where((item) => item.isPending).length} pending'),
              if (requests.recipeRequests.isEmpty)
                const EmptyStateView(title: 'No recipe requests', message: 'Recipe wishes from users will appear here.')
              else
                for (final request in requests.recipeRequests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(request.title, style: Theme.of(context).textTheme.titleMedium)),
                          Chip(label: Text(request.status.toUpperCase())),
                        ]),
                        const SizedBox(height: 5),
                        Text('Requested by ${request.requesterName} · ${request.requesterRole}'),
                        if (request.details.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(request.details),
                        ],
                        if (request.isPending) ...[
                          const SizedBox(height: 14),
                          Wrap(spacing: 10, runSpacing: 8, children: [
                            OutlinedButton(
                              onPressed: requests.busy ? null : () => _setRecipeStatus(context, request, 'accepted'),
                              child: const Text('Accept request'),
                            ),
                            TextButton(
                              onPressed: requests.busy ? null : () => _setRecipeStatus(context, request, 'rejected'),
                              child: const Text('Reject'),
                            ),
                          ]),
                        ],
                      ]),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
