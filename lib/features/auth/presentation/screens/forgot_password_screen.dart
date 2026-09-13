import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthPageLayout(
      title: 'Back to your kitchen.',
      subtitle: 'Enter your email and we will send you a password reset link.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_sent) ...[
              const InfoBanner(
                'If an account exists for that address, a reset email is on its way. Check your spam folder too.',
                icon: Icons.mark_email_read_outlined,
              ),
              const SizedBox(height: 16),
            ],
            ErrorNotice(auth.errorMessage),
            TextFormField(
              controller: _email,
              validator: InputValidators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: _sent ? 'Send again' : 'Send reset email',
              icon: Icons.send_rounded,
              loading: auth.busy,
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                FocusScope.of(context).unfocus();
                final ok = await auth.resetPassword(_email.text);
                if (!mounted) return;
                if (ok) {
                  setState(() => _sent = true);
                  showMessage(context, 'Password reset email requested.');
                } else {
                  showMessage(context, auth.errorMessage ?? 'Could not send the reset email.');
                }
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: auth.busy
                  ? null
                  : () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => route.isFirst,
                      ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
