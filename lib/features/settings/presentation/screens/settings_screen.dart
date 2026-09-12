import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final demo = context.watch<AuthProvider>().isDemo;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: FeaturePage(
          eyebrow: 'Make it yours',
          title: 'Just the way you like it.',
          subtitle: "A few small touches to make Liza's Kitchen feel perfectly at home on your device.",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ErrorNotice(settings.errorMessage),
              const _PalettePreview(),
              const SizedBox(height: 28),
              const SectionHeading(
                'Appearance',
                subtitle: 'Choose the mood that feels most comfortable to you.',
              ),
              SurfaceCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  children: [
                    for (final mode in ThemeMode.values)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            switch (mode) {
                              ThemeMode.system => Icons.brightness_auto_rounded,
                              ThemeMode.light => Icons.light_mode_outlined,
                              ThemeMode.dark => Icons.dark_mode_outlined,
                            },
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          switch (mode) {
                            ThemeMode.system => 'Follow device setting',
                            ThemeMode.light => 'Light & airy',
                            ThemeMode.dark => 'Evening rose',
                          },
                        ),
                        subtitle: Text(
                          switch (mode) {
                            ThemeMode.system => 'Match the appearance of your phone or computer',
                            ThemeMode.light => 'Cream, off-white, and baby-pink surfaces',
                            ThemeMode.dark => 'A deeper cocoa-and-rose version of the same palette',
                          },
                        ),
                        trailing: settings.themeMode == mode
                            ? Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: settings.busy ? null : () => settings.setTheme(mode),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const SectionHeading(
                'Your data',
                subtitle: 'A quick note about where your kitchen information lives.',
              ),
              InfoBanner(
                demo
                    ? 'Local demo mode: workspace data is stored on this device only. No real account is created.'
                    : AppConfig.useEmulators
                        ? 'Firebase emulator mode: accounts and kitchen data are stored in your local emulator project.'
                        : 'Firebase mode: favorites, profile, groceries, pantry, and meal plans belong to your signed-in account.',
                icon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 16),
              const SurfaceCard(
                child: Text(
                  'Theme preference and cooking progress stay on this device in every mode. '
                  'Cooking timers use saved deadlines, but do not schedule background notifications. '
                  'Keep the app open or use a separate kitchen alarm when an audible alert is important.',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const BrandMark(compact: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Liza's Kitchen", style: Theme.of(context).textTheme.titleMedium),
                        Text('Version 1.0.0 · made with a little love', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  const _PalettePreview();

  @override
  Widget build(BuildContext context) => SurfaceCard(
        tint: Theme.of(context).brightness == Brightness.dark ? null : AppTheme.offWhite,
        child: Row(
          children: [
            const _Swatch(color: AppTheme.babyPink, label: 'Baby pink'),
            const SizedBox(width: 12),
            const _Swatch(color: AppTheme.cream, label: 'Cream'),
            const SizedBox(width: 12),
            const _Swatch(color: AppTheme.offWhite, label: 'Off white'),
          ],
        ),
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.line),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      );
}
