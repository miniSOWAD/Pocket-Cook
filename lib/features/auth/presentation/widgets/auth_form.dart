import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../providers/auth_provider.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({super.key, required this.title, required this.subtitle, required this.child});
  final String title, subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Savor')),
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Align(alignment: Alignment.centerLeft, child: CircleAvatar(radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.spa_rounded, color: Theme.of(context).colorScheme.primary, size: 31))),
          const SizedBox(height: 26), Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10), Text(subtitle), const SizedBox(height: 30), child,
        ]))))));
}

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, this.register = false});
  final bool register;
  @override
  State<AuthForm> createState() => _AuthFormState();
}
class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(), _password = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = widget.register ? await auth.register(_name.text, _email.text, _password.text)
      : await auth.signIn(_email.text, _password.text);
    if (mounted && ok) Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isDemo) {
      return AuthPageLayout(title: 'Your kitchen, ready to explore.',
        subtitle: 'Try the complete local experience before connecting Firebase.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const InfoBanner('This is a local demo workspace, not a real account. No email or password is required. '
            'Favorites, groceries, and meal plans stay on this device.'),
          const SizedBox(height: 24), ErrorNotice(auth.errorMessage),
          AppButton(label: 'Enter demo workspace', icon: Icons.kitchen_rounded, loading: auth.busy,
            onPressed: () async {
              final ok = await auth.enterDemo();
              if (context.mounted && ok) Navigator.pop(context, true);
            }),
          const SizedBox(height: 12), TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep browsing as a guest')),
        ]));
    }
    return AuthPageLayout(title: widget.register ? 'A fresh start in your kitchen.' : 'Welcome back, home cook.',
      subtitle: widget.register ? 'Create an account to save recipes and plan your week.' : 'Sign in to your recipes, meal plans, and grocery list.',
      child: AutofillGroup(child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ErrorNotice(auth.errorMessage),
        if (widget.register) ...[
          TextFormField(controller: _name, validator: InputValidators.name, textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name], decoration: const InputDecoration(labelText: 'Your name')),
          const SizedBox(height: 16),
        ],
        TextFormField(controller: _email, validator: InputValidators.email, keyboardType: TextInputType.emailAddress,
          autocorrect: false, autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded))),
        const SizedBox(height: 16),
        TextFormField(controller: _password, obscureText: _obscure, autocorrect: false,
          enableSuggestions: false, autofillHints: [widget.register ? AutofillHints.newPassword : AutofillHints.password],
          validator: widget.register ? InputValidators.password : (value) => (value ?? '').isEmpty ? 'Enter your password.' : null,
          onFieldSubmitted: (_) { if (!auth.busy) _submit(); },
          decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(tooltip: _obscure ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        if (widget.register) ...[
          const SizedBox(height: 16), TextFormField(obscureText: true, autocorrect: false, enableSuggestions: false,
            validator: (value) => value == _password.text ? null : 'Passwords do not match.',
            decoration: const InputDecoration(labelText: 'Confirm password')),
        ],
        const SizedBox(height: 12),
        if (!widget.register) Align(alignment: Alignment.centerRight, child: TextButton(
          onPressed: auth.busy ? null : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          child: const Text('Forgot password?'))),
        const SizedBox(height: 12), AppButton(label: widget.register ? 'Create account' : 'Sign in',
          loading: auth.busy, onPressed: _submit),
        const SizedBox(height: 14), TextButton(onPressed: auth.busy ? null : () async {
          auth.clearError();
          if (widget.register) { Navigator.pop(context, false); return; }
          final registered = await Navigator.pushNamed<bool>(context, AppRoutes.register);
          if (context.mounted && registered == true) Navigator.pop(context, true);
        }, child: Text(widget.register ? 'Already have an account? Sign in' : 'New here? Create an account')),
      ]))));
  }
}
