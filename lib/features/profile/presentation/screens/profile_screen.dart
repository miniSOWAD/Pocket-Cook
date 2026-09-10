import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
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
    return FeaturePage(title: 'Your little corner.', subtitle: 'A kitchen that feels like you.', eyebrow: 'Made personal',
      child: user == null ? const SignInPrompt(message: 'Enter your workspace to keep favorites, organize groceries, and plan meals.')
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(profile.errorMessage, onRetry: profile.retry), ErrorNotice(auth.errorMessage),
        SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [CircleAvatar(radius: 30, child: Text(name.isEmpty ? 'S' : name[0].toUpperCase(), style: const TextStyle(fontSize: 25))),
            const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 5),
              Text(user.isDemo ? 'Local demo workspace' : user.email),
            ]))]),
          if ((profile.profile?.bio ?? '').isNotEmpty) ...[const SizedBox(height: 18), Text(profile.profile!.bio)],
          const SizedBox(height: 20), OutlinedButton.icon(onPressed: profile.loading ? null : () => Navigator.pushNamed(context, AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined), label: const Text('Edit profile')),
        ])),
        const SizedBox(height: 22), Wrap(spacing: 12, runSpacing: 12, children: [
          _Stat(label: 'Saved recipes', value: context.watch<FavoritesProvider>().ids.length),
          _Stat(label: 'Planned meals', value: context.watch<MealPlanProvider>().entries.length),
          _Stat(label: 'Grocery items', value: context.watch<GroceryProvider>().items.length),
        ]),
        const SizedBox(height: 26), SurfaceCard(padding: EdgeInsets.zero, child: Column(children: [
          ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.tune_rounded), title: const Text('Settings & appearance'),
            trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.pushNamed(context, AppRoutes.settings)),
          const Divider(), ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.info_outline_rounded), title: const Text('About Savor'),
            subtitle: const Text('A calmer way to discover, plan, and cook.'),
            onTap: () => showAboutDialog(context: context, applicationName: 'Savor', applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.spa_rounded, size: 36),
              children: const [Text('Built with Flutter, Provider, and optional Firebase. Recipe images are original illustrations. '
                'Sample recipes are demonstration content, not personalized dietary advice.')]))
        ])),
        const SizedBox(height: 22),
        if (user.isDemo) const InfoBanner('Demo data stays on this device. Leaving the workspace hides it; entering again restores it. '
          'Real, cross-device accounts require Firebase mode.'),
        const SizedBox(height: 22), OutlinedButton.icon(onPressed: auth.busy ? null : () async {
          final ok = await auth.signOut();
          if (!context.mounted) return;
          if (ok) Navigator.of(context).popUntil((route) => route.isFirst);
          showMessage(context, ok ? 'You are now browsing as a guest.' : auth.errorMessage ?? 'Sign out failed.');
        }, icon: const Icon(Icons.logout_rounded), label: Text(user.isDemo ? 'Leave demo workspace' : 'Sign out')),
      ]));
  }
}
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => SizedBox(width: 158, child: SurfaceCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$value', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 6), Text(label),
    ])));
}
