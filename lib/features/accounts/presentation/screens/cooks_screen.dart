import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common.dart';
import '../../models/app_role.dart';
import '../providers/cook_directory_provider.dart';

class CooksScreen extends StatelessWidget {
  const CooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final directory = context.watch<CookDirectoryProvider>();
    return FeaturePage(
      title: 'Meet the cooks.',
      subtitle: 'The people creating and caring for recipes inside Pocket Cook.',
      eyebrow: 'Kitchen community',
      pageKey: 'cooks',
      child: directory.loading
          ? const LoadingView()
          : directory.errorMessage != null
              ? ErrorNotice(directory.errorMessage)
              : directory.cooks.isEmpty
                  ? const EmptyStateView(
                      title: 'No cooks yet',
                      message: 'Approved cooks will appear here.',
                    )
                  : LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 900 ? 3 : width >= 560 ? 2 : 1;
                      final itemWidth = (width - (columns - 1) * 16) / columns;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final cook in directory.cooks)
                            SizedBox(
                              width: itemWidth,
                              child: SurfaceCard(
                                child: Row(
                                  children: [
                                    ProfileAvatar(photoUrl: cook.photoUrl, size: 58),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cook.displayName, style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 5),
                                          Chip(
                                            visualDensity: VisualDensity.compact,
                                            avatar: Icon(
                                              cook.role == AppRole.admin
                                                  ? Icons.admin_panel_settings_outlined
                                                  : Icons.restaurant_menu_rounded,
                                              size: 16,
                                            ),
                                            label: Text(cook.role.label),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
    );
  }
}
