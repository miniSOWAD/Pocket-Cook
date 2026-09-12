import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../meal_planner/presentation/providers/meal_plan_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.user;
    final name = profile.profile?.displayName ?? user?.name ?? 'Home cook';
    final scheme = Theme.of(context).colorScheme;

    return FeaturePage(
      title: 'Your little corner.',
      subtitle: 'Saved tastes, thoughtful plans, and the details that make this kitchen feel like yours.',
      eyebrow: 'Made personal',
      child: user == null
          ? const SignInPrompt(
              message: 'Enter your workspace to keep favorites, organize groceries, and plan meals.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ErrorNotice(profile.errorMessage, onRetry: profile.retry),
                ErrorNotice(auth.errorMessage),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? const [Color(0xFF603341), Color(0xFF332429)]
                          : const [AppTheme.softPink, AppTheme.softCream, AppTheme.offWhite],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      final avatar = Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.dustyRose.withValues(alpha: 0.13),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            name.isEmpty ? 'L' : name[0].toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: scheme.primary),
                          ),
                        ),
                      );
                      final copy = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 5),
                          Text(
                            user.isDemo ? 'Local demo workspace' : user.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if ((profile.profile?.bio ?? '').isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(profile.profile!.bio),
                          ],
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: profile.loading ? null : () => Navigator.pushNamed(context, AppRoutes.editProfile),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit profile'),
                          ),
                        ],
                      );
                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [avatar, const SizedBox(height: 20), copy],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [avatar, const SizedBox(width: 22), Expanded(child: copy)],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),
                const SectionHeading(
                  'Your kitchen at a glance',
                  subtitle: 'A tiny snapshot of the things you are collecting and planning.',
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Stat(
                      icon: Icons.favorite_rounded,
                      label: 'Saved recipes',
                      value: context.watch<FavoritesProvider>().ids.length,
                    ),
                    _Stat(
                      icon: Icons.calendar_month_rounded,
                      label: 'Planned meals',
                      value: context.watch<MealPlanProvider>().entries.length,
                    ),
                    _Stat(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Grocery items',
                      value: context.watch<GroceryProvider>().items.length,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: _TileIcon(icon: Icons.tune_rounded),
                        title: const Text('Settings & appearance'),
                        subtitle: const Text('Theme and local preferences'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: const _TileIcon(icon: Icons.favorite_outline_rounded),
                        title: const Text("About Liza's Kitchen"),
                        subtitle: const Text('A softer way to discover, plan, and cook.'),
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: "Liza's Kitchen",
                          applicationVersion: '1.0.0',
                          applicationIcon: const BrandMark(),
                          children: const [
                            Text(
                              'Built with Flutter, Provider, and optional Firebase. Recipe images are original illustrations. '
                              'Sample recipes are demonstration content, not personalized dietary advice.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (user.isDemo)
                  const InfoBanner(
                    'Demo data stays on this device. Leaving the workspace hides it; entering again restores it. '
                    'Real, cross-device accounts require Firebase mode.',
                    icon: Icons.favorite_outline_rounded,
                  ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: auth.busy
                      ? null
                      : () async {
                          final ok = await auth.signOut();
                          if (!context.mounted) return;
                          if (ok) Navigator.of(context).popUntil((route) => route.isFirst);
                          showMessage(
                            context,
                            ok ? 'You are now browsing as a guest.' : auth.errorMessage ?? 'Sign out failed.',
                          );
                        },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(user.isDemo ? 'Leave demo workspace' : 'Sign out'),
                ),
              ],
            ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 172,
        child: SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 15),
              Text('$value', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
