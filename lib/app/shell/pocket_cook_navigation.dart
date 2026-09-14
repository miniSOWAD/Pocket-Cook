import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../router/app_routes.dart';

class PocketCookDestination {
  const PocketCookDestination({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
}

const pocketCookDestinations = <PocketCookDestination>[
  PocketCookDestination(
    label: 'Home',
    shortLabel: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  PocketCookDestination(
    label: 'Saved',
    shortLabel: 'Saved',
    icon: Icons.favorite_border_rounded,
    selectedIcon: Icons.favorite_rounded,
  ),
  PocketCookDestination(
    label: 'Plan',
    shortLabel: 'Plan',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
  ),
  PocketCookDestination(
    label: 'Groceries',
    shortLabel: 'Shop',
    icon: Icons.shopping_bag_outlined,
    selectedIcon: Icons.shopping_bag_rounded,
  ),
  PocketCookDestination(
    label: 'Pantry',
    shortLabel: 'Pantry',
    icon: Icons.kitchen_outlined,
    selectedIcon: Icons.kitchen_rounded,
  ),
  PocketCookDestination(
    label: 'Make ur plate',
    shortLabel: 'Plate',
    icon: Icons.ramen_dining_outlined,
    selectedIcon: Icons.ramen_dining_rounded,
  ),
  PocketCookDestination(
    label: 'Cooks',
    shortLabel: 'Cooks',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups_rounded,
  ),
];

void openPocketCookDestination(BuildContext context, int index) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
    arguments: index,
  );
}

class PocketCookGlassNavigationBar extends StatelessWidget {
  const PocketCookGlassNavigationBar({
    super.key,
    this.selectedIndex,
    required this.onDestinationSelected,
    this.compactLabels = false,
  });

  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final bool compactLabels;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 9),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            Colors.white.withValues(alpha: 0.08),
                            const Color(0xFF1B5A65).withValues(alpha: 0.17),
                            const Color(0xFF343A73).withValues(alpha: 0.13),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.30),
                            AppTheme.lightCyan.withValues(alpha: 0.20),
                            AppTheme.lightIndigo.withValues(alpha: 0.18),
                            AppTheme.lightestOrange.withValues(alpha: 0.13),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.72),
                    width: 1.15,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.deepCyan.withValues(alpha: dark ? 0.15 : 0.09),
                      blurRadius: 34,
                      spreadRadius: -7,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: dark ? 0.03 : 0.48),
                      blurRadius: 10,
                      spreadRadius: -4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24,
                      right: 24,
                      top: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: dark ? 0.18 : 0.88),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < pocketCookDestinations.length; i++)
                          Expanded(
                            child: _GlassNavItem(
                              destination: pocketCookDestinations[i],
                              selected: selectedIndex == i,
                              compactLabels: compactLabels,
                              enabled: onDestinationSelected != null,
                              foreground: scheme.onSurfaceVariant,
                              selectedForeground: scheme.onSurface,
                              onTap: onDestinationSelected == null
                                  ? null
                                  : () => onDestinationSelected!(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.destination,
    required this.selected,
    required this.compactLabels,
    required this.enabled,
    required this.foreground,
    required this.selectedForeground,
    required this.onTap,
  });

  final PocketCookDestination destination;
  final bool selected;
  final bool compactLabels;
  final bool enabled;
  final Color foreground;
  final Color selectedForeground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 42 : 34,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightIndigo.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.55))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: selected
                        ? Border.all(color: Colors.white.withValues(alpha: 0.38))
                        : null,
                  ),
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 21,
                    color: selected ? scheme.primary : foreground,
                  ),
                ),
                if (selected || !compactLabels) ...[
                  const SizedBox(height: 2),
                  Text(
                    compactLabels ? destination.shortLabel : destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9.2,
                          height: 1,
                          color: selected ? selectedForeground : foreground,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps routed pages so the primary Pocket Cook navigation remains available
/// even while the user is inside recipe details, profile, admin, auth, cooking,
/// settings, or request flows.
class GlobalPocketCookNavigationFrame extends StatelessWidget {
  const GlobalPocketCookNavigationFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      bottomNavigationBar: PocketCookGlassNavigationBar(
        compactLabels: false,
        onDestinationSelected: (index) => openPocketCookDestination(context, index),
      ),
    );
  }
}
