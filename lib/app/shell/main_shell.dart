import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../features/accounts/models/app_role.dart';
import '../../features/accounts/presentation/providers/account_provider.dart';
import '../../features/accounts/presentation/screens/cooks_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/grocery_list/presentation/screens/grocery_list_screen.dart';
import '../../features/meal_planner/presentation/screens/meal_planner_screen.dart';
import '../../features/make_plate/presentation/screens/make_plate_screen.dart';
import '../../features/pantry/presentation/screens/pantry_screen.dart';
import '../../features/recipes/presentation/screens/home_screen.dart';
import '../../features/requests/presentation/providers/request_provider.dart';
import '../router/app_routes.dart';
import 'pocket_cook_navigation.dart';

enum _ProfileMenuAction {
  profile,
  favourites,
  requestRecipe,
  becomeCook,
  manageUsers,
  cookRequests,
  manageRecipes,
  logout,
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, pocketCookDestinations.length - 1).toInt();
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex.clamp(0, pocketCookDestinations.length - 1).toInt();
    }
  }

  Future<void> _becomeCook() async {
    final requests = context.read<RequestProvider>();
    if (requests.cookApplication?.isPending == true) {
      showMessage(context, 'Your Cook request is already waiting for Admin review.');
      return;
    }
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Become a Cook'),
        content: SizedBox(
          width: 460,
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            maxLength: 400,
            decoration: const InputDecoration(
              labelText: 'A note for the Admin (optional)',
              hintText: 'Tell us a little about what you love to cook.',
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (message == null || !mounted) return;
    final ok = await requests.becomeCook(message);
    if (!mounted) return;
    showMessage(
      context,
      ok ? 'Your Cook request was sent to the Admin.' : requests.errorMessage ?? 'Could not send the Cook request.',
    );
  }

  Future<void> _handleProfileMenu(_ProfileMenuAction action) async {
    switch (action) {
      case _ProfileMenuAction.profile:
        await Navigator.pushNamed(context, AppRoutes.profile);
        break;
      case _ProfileMenuAction.favourites:
        if (mounted) setState(() => _index = 1);
        break;
      case _ProfileMenuAction.requestRecipe:
        await Navigator.pushNamed(context, AppRoutes.requestRecipe);
        break;
      case _ProfileMenuAction.becomeCook:
        await _becomeCook();
        break;
      case _ProfileMenuAction.manageUsers:
        await Navigator.pushNamed(context, AppRoutes.manageUsers);
        break;
      case _ProfileMenuAction.cookRequests:
        await Navigator.pushNamed(context, AppRoutes.cookRequests);
        break;
      case _ProfileMenuAction.manageRecipes:
        await Navigator.pushNamed(context, AppRoutes.manageRecipes);
        break;
      case _ProfileMenuAction.logout:
        final auth = context.read<AuthProvider>();
        final ok = await auth.signOut();
        if (!mounted) return;
        if (ok) {
          setState(() => _index = 0);
          showMessage(context, 'You have been logged out.');
        } else {
          showMessage(context, auth.errorMessage ?? 'Log out failed.');
        }
        break;
    }
  }

  List<PopupMenuEntry<_ProfileMenuAction>> _menuItems(BuildContext context) {
    final account = context.read<AccountProvider>();
    final items = <PopupMenuEntry<_ProfileMenuAction>>[
      const PopupMenuItem(
        value: _ProfileMenuAction.profile,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.person_outline_rounded),
          title: Text('Profile'),
        ),
      ),
    ];

    if (account.isBlocked) {
      items.addAll(const [
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileMenuAction.logout,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded),
            title: Text('Log out'),
          ),
        ),
      ]);
      return items;
    }

    if (!account.roleReady) {
      items.addAll([
        const PopupMenuDivider(),
        PopupMenuItem<_ProfileMenuAction>(
          enabled: false,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(account.loading ? Icons.hourglass_top_rounded : Icons.warning_amber_rounded),
            title: Text(account.loading ? 'Loading account role...' : 'Account role unavailable'),
            subtitle: account.errorMessage == null ? null : Text(account.errorMessage!),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _ProfileMenuAction.logout,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded),
            title: Text('Log out'),
          ),
        ),
      ]);
      return items;
    }

    items.add(const PopupMenuItem(
      value: _ProfileMenuAction.favourites,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.favorite_border_rounded),
        title: Text('Favourites'),
      ),
    ));

    if (account.isAdmin) {
      items.addAll(const [
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileMenuAction.manageUsers,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.manage_accounts_outlined), title: Text('Manage users')),
        ),
        PopupMenuItem(
          value: _ProfileMenuAction.cookRequests,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.mark_email_unread_outlined), title: Text('Cook Requests')),
        ),
        PopupMenuItem(
          value: _ProfileMenuAction.manageRecipes,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.menu_book_outlined), title: Text('Manage Recipes')),
        ),
      ]);
    } else if (account.isCook) {
      items.addAll(const [
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileMenuAction.requestRecipe,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.outgoing_mail), title: Text('Request Recipe')),
        ),
        PopupMenuItem(
          value: _ProfileMenuAction.manageRecipes,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.menu_book_outlined), title: Text('Manage Recipes')),
        ),
      ]);
    } else if (account.isVisitor) {
      items.addAll(const [
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileMenuAction.requestRecipe,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.outgoing_mail), title: Text('Request Recipe')),
        ),
        PopupMenuItem(
          value: _ProfileMenuAction.becomeCook,
          child: ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.restaurant_menu_rounded), title: Text('Become Cook')),
        ),
      ]);
    }

    items.addAll(const [
      PopupMenuDivider(),
      PopupMenuItem(
        value: _ProfileMenuAction.logout,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.logout_rounded),
          title: Text('Log out'),
        ),
      ),
    ]);
    return items;
  }

  Widget _accountAction(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final account = context.watch<AccountProvider>();
    final user = auth.user;
    if (user == null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: FilledButton.tonalIcon(
          onPressed: auth.busy ? null : () => Navigator.pushNamed(context, AppRoutes.login),
          icon: const Icon(Icons.person_outline_rounded, size: 18),
          label: const Text('Sign in'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: PopupMenuButton<_ProfileMenuAction>(
        tooltip: '${account.roleLabel} account menu',
        onSelected: _handleProfileMenu,
        offset: const Offset(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        itemBuilder: _menuItems,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ProfileAvatar(
              photoUrl: user.photoUrl,
              size: 44,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF253E48)
                  : AppTheme.lightIndigo,
            ),
            if (account.isAdmin || account.isCook)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: account.isAdmin ? Theme.of(context).colorScheme.primary : AppTheme.lightOrange,
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                  ),
                  child: Icon(
                    account.isAdmin ? Icons.admin_panel_settings_rounded : Icons.restaurant_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final auth = context.watch<AuthProvider>();
    final account = context.watch<AccountProvider>();
    final scheme = Theme.of(context).colorScheme;

    final body = account.isBlocked && auth.user != null
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: EmptyStateView(
                title: 'This account is blocked',
                message: 'An Admin has disabled this account. Contact the site administrator if you think this is a mistake.',
              ),
            ),
          )
        : IndexedStack(
            index: _index,
            children: [
              HomeScreen(onOpenMakePlate: () => setState(() => _index = 5)),
              const FavoritesScreen(),
              const MealPlannerScreen(),
              const GroceryListScreen(),
              const PantryScreen(),
              const MakePlateScreen(),
              const CooksScreen(),
            ],
          );

    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: !wide,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF113139), Color(0xFF252A49), Color(0xFF3D3023)],
                  )
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0, 0.58, 1.0],
                    colors: [
                      AppTheme.lightCyan,
                      AppTheme.lightIndigo,
                      AppTheme.lightestOrange,
                    ],
                  ),
            border: Border(
              bottom: BorderSide(
                color: dark ? const Color(0xFF41636C) : const Color(0xFFCADDE8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.18)
                    : AppTheme.deepCyan.withValues(alpha: 0.09),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.only(left: 18, top: 10, bottom: 10),
          child: BrandMark(compact: true),
        ),
        titleSpacing: 8,
        title: wide
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pocket Cook',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          letterSpacing: -0.6,
                        ),
                  ),
                  Text(
                    'Cook smarter. Waste less.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              )
            : Text(
                'Pocket Cook',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      letterSpacing: -0.6,
                    ),
              ),
        actions: [
          if (auth.isDemo || AppConfig.useEmulators)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.science_outlined, size: 13),
                label: Text(
                  auth.isDemo ? 'LOCAL DEMO' : 'EMULATOR',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          _accountAction(context),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: wide
            ? Row(
                children: [
                  Container(
                    width: 212,
                    margin: const EdgeInsets.fromLTRB(16, 18, 0, 18),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.82),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepCyan.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: NavigationRail(
                      selectedIndex: _index,
                      extended: true,
                      minExtendedWidth: 210,
                      groupAlignment: -0.74,
                      onDestinationSelected: account.isBlocked
                          ? null
                          : (index) => setState(() => _index = index),
                      destinations: [
                        for (final destination in pocketCookDestinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
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
          : PocketCookGlassNavigationBar(
              selectedIndex: _index,
              compactLabels: true,
              onDestinationSelected: account.isBlocked
                  ? null
                  : (index) => setState(() => _index = index),
            ),
    );
  }
}
