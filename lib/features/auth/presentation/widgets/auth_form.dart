import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../providers/auth_provider.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title, subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: 40,
              child: _AuthBlob(size: 210, color: scheme.primaryContainer.withValues(alpha: 0.65)),
            ),
            Positioned(
              left: -55,
              bottom: 30,
              child: _AuthBlob(size: 160, color: AppTheme.orangeWash.withValues(alpha: 0.72)),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back',
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text(
                            "Pocket Cook",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Align(alignment: Alignment.centerLeft, child: BrandMark()),
                      const SizedBox(height: 26),
                      const Eyebrow('Cook smart, waste less'),
                      const SizedBox(height: 14),
                      Text(title, style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 30),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_rounded, size: 13, color: AppTheme.lightOrange.withValues(alpha: 0.7)),
                          const SizedBox(width: 7),
                          Text(
                            'recipes · pantry · smart plates',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBlob extends StatelessWidget {
  const _AuthBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size * 0.45),
              topRight: Radius.circular(size * 0.25),
              bottomLeft: Radius.circular(size * 0.28),
              bottomRight: Radius.circular(size * 0.48),
            ),
          ),
        ),
      );
}

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, this.register = false});
  final bool register;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = widget.register
        ? await auth.register(_name.text, _email.text, _password.text)
        : await auth.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }
    showMessage(
      context,
      auth.errorMessage ?? (widget.register ? 'Sign up failed.' : 'Sign in failed.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isDemo) {
      return AuthPageLayout(
        title: 'Make yourself at home.',
        subtitle: "Step into Pocket Cook and explore the complete local experience before connecting Firebase.",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const InfoBanner(
              'This is a local demo workspace, not a real account. No email or password is required. '
              'Favorites, groceries, and meal plans stay on this device.',
              icon: Icons.offline_bolt_outlined,
            ),
            const SizedBox(height: 24),
            ErrorNotice(auth.errorMessage),
            AppButton(
              label: 'Enter my kitchen',
              icon: Icons.kitchen_rounded,
              loading: auth.busy,
              onPressed: () async {
                final ok = await auth.enterDemo();
                if (context.mounted && ok) Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep browsing as a guest'),
            ),
          ],
        ),
      );
    }

    return AuthPageLayout(
      title: widget.register ? 'Create your Pocket Cook account.' : 'Welcome back to Pocket Cook.',
      subtitle: widget.register
          ? 'Create an account to keep your favorite recipes, plans, and kitchen notes together.'
          : 'Sign in to your recipes, meal plans, grocery list, and pantry.',
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorNotice(auth.errorMessage),
              if (widget.register) ...[
                TextFormField(
                  controller: _name,
                  validator: InputValidators.name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _email,
                validator: InputValidators.email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: [widget.register ? AutofillHints.newPassword : AutofillHints.password],
                validator: widget.register
                    ? InputValidators.password
                    : (value) => (value ?? '').isEmpty ? 'Enter your password.' : null,
                onFieldSubmitted: (_) {
                  if (!auth.busy) _submit();
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              if (widget.register) ...[
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => value == _password.text ? null : 'Passwords do not match.',
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: Icon(Icons.favorite_outline_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (!widget.register)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: auth.busy ? null : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
              const SizedBox(height: 12),
              AppButton(
                label: widget.register ? 'Sign up' : 'Sign in',
                icon: widget.register ? Icons.favorite_outline_rounded : Icons.arrow_forward_rounded,
                loading: auth.busy,
                onPressed: _submit,
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: auth.busy
                    ? null
                    : () async {
                        auth.clearError();
                        if (widget.register) {
                          Navigator.pop(context);
                          return;
                        }
                        // This router creates MaterialPageRoute<dynamic>. Requesting a
                        // bool result here makes Flutter Web cast that route to
                        // Route<bool?> before it can open the sign-up page, which throws.
                        // Registration already redirects to the home page on success, so
                        // no typed route result is needed here.
                        await Navigator.pushNamed(context, AppRoutes.register);
                      },
                child: Text(
                  widget.register
                      ? 'Already have an account? Sign in'
                      : 'No account? Sign up',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
