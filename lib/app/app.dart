import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'router/app_router.dart';

class LizasKitchenApp extends StatefulWidget {
  const LizasKitchenApp({super.key});
  @override
  State<LizasKitchenApp> createState() => _LizasKitchenAppState();
}
class _LizasKitchenAppState extends State<LizasKitchenApp> {
  AuthProvider? _auth;
  String? _lastUid;
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (identical(auth, _auth)) return;
    _auth?.removeListener(_sessionChanged);
    _auth = auth;
    _lastUid = auth.user?.uid;
    auth.addListener(_sessionChanged);
  }
  void _sessionChanged() {
    final nextUid = _auth?.user?.uid;
    final resetNavigation = _lastUid != null && _lastUid != nextUid;
    _lastUid = nextUid;
    // Old forms and modal sheets can contain private snapshots. Dispose the
    // entire old route stack when leaving or replacing an authenticated session.
    // Guest -> signed-in preserves the pending recipe action's login route.
    if (resetNavigation && mounted) {
      setState(() => _navigatorKey = GlobalKey<NavigatorState>());
    }
  }
  @override
  void dispose() { _auth?.removeListener(_sessionChanged); super.dispose(); }
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "Liza's Kitchen", debugShowCheckedModeBanner: false, navigatorKey: _navigatorKey,
    theme: AppTheme.build(Brightness.light), darkTheme: AppTheme.build(Brightness.dark),
    themeMode: context.watch<SettingsProvider>().themeMode,
    onGenerateRoute: AppRouter.onGenerateRoute,
  );
}
