import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/grocery_list/presentation/screens/grocery_list_screen.dart';
import '../../features/meal_planner/presentation/screens/meal_planner_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/recipes/presentation/screens/home_screen.dart';
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int _index = 0;
  static const _destinations = [
    (label: 'Discover', icon: Icons.explore_outlined, selected: Icons.explore_rounded),
    (label: 'Saved', icon: Icons.favorite_border_rounded, selected: Icons.favorite_rounded),
    (label: 'Plan', icon: Icons.calendar_month_outlined, selected: Icons.calendar_month_rounded),
    (label: 'Groceries', icon: Icons.shopping_bag_outlined, selected: Icons.shopping_bag_rounded),
    (label: 'You', icon: Icons.person_outline_rounded, selected: Icons.person_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final auth = context.watch<AuthProvider>();
    final body = IndexedStack(index: _index, children: const [HomeScreen(), FavoritesScreen(),
      MealPlannerScreen(), GroceryListScreen(), ProfileScreen()]);
    return Scaffold(
      appBar: AppBar(leading: Padding(padding: const EdgeInsets.only(left: 18),
        child: Icon(Icons.spa_rounded, color: Theme.of(context).colorScheme.primary, size: 29)),
        title: const Text('Savor', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
        actions: [if (auth.isDemo || AppConfig.useEmulators) Padding(padding: const EdgeInsets.only(right: 12),
          child: Chip(label: Text(auth.isDemo ? 'LOCAL DEMO' : 'EMULATOR', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
          IconButton(tooltip: 'Your profile', onPressed: () => setState(() => _index = 4), icon: const Icon(Icons.account_circle_outlined)),
          const SizedBox(width: 12)]),
      body: SafeArea(bottom: false, child: wide ? Row(children: [
        NavigationRail(selectedIndex: _index, extended: true, minExtendedWidth: 180,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onDestinationSelected: (index) => setState(() => _index = index), destinations: [
            for (final destination in _destinations) NavigationRailDestination(icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selected), label: Text(destination.label)),
          ]), const VerticalDivider(width: 1), Expanded(child: body),
      ]) : body),
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index), destinations: [
          for (final destination in _destinations) NavigationDestination(icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selected), label: destination.label),
        ]),
    );
  }
}
