import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../providers/profile_provider.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}
class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _bio;
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: profile?.displayName ?? context.read<AuthProvider>().user?.name ?? '');
    _bio = TextEditingController(text: profile?.bio ?? '');
  }
  @override
  void dispose() { _name.dispose(); _bio.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    return Scaffold(appBar: AppBar(title: const Text('Edit profile')), body: SafeArea(child: FeaturePage(
      title: 'Make yourself at home.', subtitle: 'A name and a few words about your cooking style.',
      child: context.watch<AuthProvider>().user == null ? const SignInPrompt(message: 'Sign in to edit your profile.')
      : Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ErrorNotice(profile.errorMessage), TextFormField(controller: _name, validator: InputValidators.name,
          maxLength: 60, decoration: const InputDecoration(labelText: 'Display name')),
        const SizedBox(height: 18), TextFormField(controller: _bio, maxLength: 240, minLines: 3, maxLines: 5,
          decoration: const InputDecoration(labelText: 'A little about you', hintText: 'Weeknight pasta enthusiast...')),
        const SizedBox(height: 24), AppButton(label: 'Save profile', icon: Icons.check_rounded, loading: profile.busy,
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            final ok = await profile.save(_name.text, _bio.text);
            if (context.mounted && ok) { showMessage(context, 'Profile updated.'); Navigator.pop(context); }
          }),
      ])))));
  }
}
