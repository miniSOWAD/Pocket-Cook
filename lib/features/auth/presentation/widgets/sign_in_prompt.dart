import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/auth_guard.dart';
import '../../../../core/widgets/common.dart';
import '../providers/auth_provider.dart';
class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final demo = context.watch<AuthProvider>().isDemo;
    return EmptyStateView(icon: Icons.kitchen_rounded, title: 'Make this kitchen yours',
      message: message, action: AppButton(label: demo ? 'Enter demo workspace' : 'Sign in',
        icon: Icons.person_outline_rounded, onPressed: () => ensureSignedIn(context)));
  }
}
