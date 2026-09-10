import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final demo = context.watch<AuthProvider>().isDemo;
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: SafeArea(child: FeaturePage(
      title: 'Just the way you like it.', subtitle: 'A few small things to make Savor feel right.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ErrorNotice(settings.errorMessage), const SectionHeading('Appearance'),
        SurfaceCard(child: Column(children: [
          for (final mode in ThemeMode.values) ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(switch (mode) { ThemeMode.system => Icons.brightness_auto_rounded,
              ThemeMode.light => Icons.light_mode_outlined, ThemeMode.dark => Icons.dark_mode_outlined }),
            title: Text(switch (mode) { ThemeMode.system => 'Follow device setting', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark' }),
            trailing: settings.themeMode == mode ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: settings.busy ? null : () => settings.setTheme(mode)),
        ])),
        const SizedBox(height: 28), const SectionHeading('Your data'),
        InfoBanner(demo ? 'Local demo mode: workspace data is stored on this device only. No real account is created.'
          : AppConfig.useEmulators ? 'Firebase emulator mode: accounts and kitchen data are stored in your local emulator project.'
          : 'Firebase mode: favorites, profile, groceries, and meal plans belong to your signed-in account.'),
        const SizedBox(height: 16),
        const SurfaceCard(child: Text('Theme preference and cooking progress stay on this device in every mode. '
          'Cooking timers use saved deadlines, but do not schedule background notifications. '
          'Keep the app open or use a separate kitchen alarm when an audible alert is important.')),
        const SizedBox(height: 26), Text('Savor 1.0.0', style: Theme.of(context).textTheme.bodySmall),
      ]))));
  }
}
