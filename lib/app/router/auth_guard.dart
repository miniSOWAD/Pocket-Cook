import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_routes.dart';
Future<bool> ensureSignedIn(BuildContext context) async {
  if (context.read<AuthProvider>().user != null) return true;
  await Navigator.of(context).pushNamed<bool>(AppRoutes.login);
  return context.mounted && context.read<AuthProvider>().user != null;
}
