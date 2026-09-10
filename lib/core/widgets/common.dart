import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
}

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, this.icon, this.onPressed, this.loading = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: loading ? null : onPressed,
    icon: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
      : Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
    label: Text(label),
  );
}

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key, required this.title, required this.subtitle, required this.child,
    this.eyebrow, this.trailing, this.pageKey});
  final String title, subtitle;
  final String? eyebrow, pageKey;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey(pageKey ?? title),
    child: Align(alignment: Alignment.topCenter, child: Container(
      constraints: const BoxConstraints(maxWidth: 1160),
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 10)],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 7),
            Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ]),
        const SizedBox(height: 28), child, const SizedBox(height: 32),
      ]),
    )),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: TextStyle(
    color: color ?? Theme.of(context).colorScheme.primary, fontSize: 11,
    fontWeight: FontWeight.w800, letterSpacing: 1.7));
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      if (action != null) action!]));
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
    child: child);
}

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.message, {super.key, this.icon = Icons.info_outline_rounded});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 21), const SizedBox(width: 12), Expanded(child: Text(message)),
    ]));
}

class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.message, {super.key, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(message!, style: TextStyle(color: scheme.onErrorContainer)),
        if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
      ])));
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(64),
    child: Center(child: CircularProgressIndicator()));
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, required this.title, required this.message,
    this.icon = Icons.restaurant_menu_rounded, this.action});
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 16),
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 410), child: Column(children: [
      CircleAvatar(radius: 35, backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, size: 31, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 20), Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10), Text(message, textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      if (action != null) ...[const SizedBox(height: 22), action!],
    ]))));
}

Future<bool> confirmAction(BuildContext context, {required String title, required String message,
  String confirmLabel = 'Continue'}) async => await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
    title: Text(title), content: Text(message), actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(confirmLabel)),
    ],
  )) ?? false;
