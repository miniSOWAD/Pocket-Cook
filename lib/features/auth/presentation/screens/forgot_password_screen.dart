import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  void dispose() { _email.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthPageLayout(title: 'Back to your kitchen.', subtitle: 'Request a password reset email.',
      child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (_sent) const InfoBanner('If an account exists for that address, a reset email will arrive. Check your spam folder too.'),
        const SizedBox(height: 16), ErrorNotice(auth.errorMessage),
        TextFormField(controller: _email, validator: InputValidators.email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address')),
        const SizedBox(height: 20), AppButton(label: 'Send reset email', loading: auth.busy,
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            final ok = await auth.resetPassword(_email.text);
            if (mounted && ok) setState(() => _sent = true);
          }),
      ])));
  }
}
