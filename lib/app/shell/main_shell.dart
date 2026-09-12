import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/grocery_list/presentation/screens/grocery_list_screen.dart';
import '../../features/meal_planner/presentation/screens/meal_planner_screen.dart';
import '../../features/pantry/presentation/screens/pantry_screen.dart';
import '../../features/recipes/presentation/screens/home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _destinations = [
    (label: 'Discover', icon: Icons.auto_awesome_outlined, selected: Icons.auto_awesome_rounded),
    (label: 'Saved', icon: Icons.favorite_border_rounded, selected: Icons.favorite_rounded),
    (label: 'Plan', icon: Icons.calendar_month_outlined, selected: Icons.calendar_month_rounded),
    (label: 'Groceries', icon: Icons.shopping_bag_outlined, selected: Icons.shopping_bag_rounded),
    (label: 'Pantry', icon: Icons.kitchen_outlined, selected: Icons.kitchen_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final body = IndexedStack(
      index: _index,
      children: const [
        HomeScreen(),
        FavoritesScreen(),
        MealPlannerScreen(),
        GroceryListScreen(),
        PantryScreen(),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        leadingWidth: 70,
        leading: const Padding(
          padding: EdgeInsets.only(left: 18, top: 8, bottom: 8),
          child: BrandMark(compact: true),
        ),
        titleSpacing: 10,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Liza's Kitchen",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 23,
                    letterSpacing: -0.7,
                  ),
            ),
            Text(
              'made with a little love',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        actions: [
          if (auth.isDemo || AppConfig.useEmulators)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.favorite_rounded, size: 13),
                label: Text(
                  auth.isDemo ? 'LOCAL DEMO' : 'EMULATOR',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton.filledTonal(
              tooltip: 'Your profile',
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: scheme.outlineVariant.withValues(alpha: 0.72),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: wide
            ? Row(
                children: [
                  Container(
                    width: 206,
                    margin: const EdgeInsets.fromLTRB(16, 18, 0, 18),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.dustyRose.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: NavigationRail(
                      selectedIndex: _index,
                      extended: true,
                      minExtendedWidth: 204,
                      groupAlignment: -0.75,
                      onDestinationSelected: (index) => setState(() => _index = index),
                      destinations: [
                        for (final destination in _destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selected),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: body),
                ],
              )
            : body,
      ),
      bottomNavigationBar: wide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.72))),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.dustyRose.withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (index) => setState(() => _index = index),
                destinations: [
                  for (final destination in _destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selected),
                      label: destination.label,
                    ),
                ],
              ),
            ),
    );
  }
}
