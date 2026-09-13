import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_routes.dart';
Future<bool> ensureSignedIn(BuildContext context) async {
  if (context.read<AuthProvider>().user != null) return true;
  // AppRouter returns MaterialPageRoute<dynamic>, so do not request a typed
  // bool route result. We only care whether AuthProvider has a user afterward.
  await Navigator.of(context).pushNamed(AppRoutes.login);
  return context.mounted && context.read<AuthProvider>().user != null;
}
