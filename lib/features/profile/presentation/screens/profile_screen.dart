import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../../../accounts/models/app_role.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../auth/models/auth_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/sign_in_prompt.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../grocery_list/presentation/providers/grocery_provider.dart';
import '../../../meal_planner/presentation/providers/meal_plan_provider.dart';
import '../../models/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = auth.user;

    return FeaturePage(
      title: 'Your profile.',
      subtitle: 'Keep your account details and the little things that make this kitchen feel like yours up to date.',
      eyebrow: 'Made personal',
      child: user == null
          ? const SignInPrompt(message: 'Sign in to view and edit your profile.')
          : profileProvider.loading
              ? const LoadingView()
              : _EditableProfile(
                  key: ValueKey(user.uid),
                  user: user,
                  profile: profileProvider.profile,
                ),
    );
  }
}

class _EditableProfile extends StatefulWidget {
  const _EditableProfile({
    super.key,
    required this.user,
    required this.profile,
  });

  final AuthUser user;
  final UserProfile? profile;

  @override
  State<_EditableProfile> createState() => _EditableProfileState();
}

class _EditableProfileState extends State<_EditableProfile> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _bio;
  late final TextEditingController _photoUrl;

  late String _initialName;
  late String _initialEmail;
  late String _initialBio;
  late String _initialPhotoUrl;
  bool _dirty = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _initialName = widget.profile?.displayName ?? widget.user.name;
    _initialEmail = widget.user.email;
    _initialBio = widget.profile?.bio ?? '';
    _initialPhotoUrl = widget.user.photoUrl;

    _name = TextEditingController(text: _initialName);
    _email = TextEditingController(text: _initialEmail);
    _bio = TextEditingController(text: _initialBio);
    _photoUrl = TextEditingController(text: _initialPhotoUrl);

    for (final controller in [_name, _email, _bio, _photoUrl]) {
      controller.addListener(_recomputeDirty);
    }
  }

  @override
  void didUpdateWidget(covariant _EditableProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dirty) return;

    final nextName = widget.profile?.displayName ?? widget.user.name;
    final nextEmail = widget.user.email;
    final nextBio = widget.profile?.bio ?? '';
    final nextPhoto = widget.user.photoUrl;

    _syncing = true;
    if (_name.text != nextName) _name.text = nextName;
    if (_email.text != nextEmail) _email.text = nextEmail;
    if (_bio.text != nextBio) _bio.text = nextBio;
    if (_photoUrl.text != nextPhoto) _photoUrl.text = nextPhoto;
    _initialName = nextName;
    _initialEmail = nextEmail;
    _initialBio = nextBio;
    _initialPhotoUrl = nextPhoto;
    _syncing = false;
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _bio, _photoUrl]) {
      controller.removeListener(_recomputeDirty);
      controller.dispose();
    }
    super.dispose();
  }

  void _recomputeDirty() {
    if (_syncing) return;
    final next = _name.text.trim() != _initialName.trim() ||
        _email.text.trim().toLowerCase() != _initialEmail.trim().toLowerCase() ||
        _bio.text.trim() != _initialBio.trim() ||
        _photoUrl.text.trim() != _initialPhotoUrl.trim();
    if (next != _dirty && mounted) setState(() => _dirty = next);
  }

  String? _photoValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    if (text.length > 1200) return 'The image URL is too long.';
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Use a valid http or https image URL.';
    }
    return null;
  }

  void _acceptSavedProfile({
    required String name,
    required String bio,
    required String photoUrl,
    bool resetEmail = false,
  }) {
    _syncing = true;
    _initialName = name;
    _initialBio = bio;
    _initialPhotoUrl = photoUrl;
    if (resetEmail) {
      _email.text = widget.user.email;
      _initialEmail = widget.user.email;
    }
    _syncing = false;
    _recomputeDirty();
  }

  Future<void> _save() async {
    if (!_dirty || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final name = _name.text.trim();
    final bio = _bio.text.trim();
    final photoUrl = _photoUrl.text.trim();
    final requestedEmail = _email.text.trim();
    final emailChanged = !widget.user.isDemo &&
        requestedEmail.toLowerCase() != widget.user.email.trim().toLowerCase();

    final profileSaved = await profile.save(name, bio);
    if (!mounted) return;
    if (!profileSaved) {
      showMessage(context, profile.errorMessage ?? 'Could not save your profile.');
      return;
    }

    final accountSaved = await auth.updateAccountProfile(name, photoUrl);
    if (!mounted) return;
    if (!accountSaved) {
      _acceptSavedProfile(name: name, bio: bio, photoUrl: _initialPhotoUrl);
      showMessage(
        context,
        auth.errorMessage ?? 'Your profile text was saved, but the account photo could not be updated.',
      );
      return;
    }

    final identitySynced = await context.read<AccountProvider>().syncIdentity();
    if (!mounted) return;
    if (!identitySynced) {
      showMessage(context, 'Your profile was saved, but the public Cook identity could not be refreshed yet.');
    }

    if (emailChanged) {
      final requested = await auth.requestEmailChange(requestedEmail);
      if (!mounted) return;
      if (!requested) {
        _acceptSavedProfile(name: name, bio: bio, photoUrl: photoUrl);
        showMessage(
          context,
          auth.errorMessage ?? 'Your profile was saved, but the email change could not be requested.',
        );
        return;
      }
      _acceptSavedProfile(
        name: name,
        bio: bio,
        photoUrl: photoUrl,
        resetEmail: true,
      );
      showMessage(
        context,
        'Profile saved. Check $requestedEmail and verify it before the sign-in email changes.',
      );
      return;
    }

    _initialEmail = widget.user.email;
    _acceptSavedProfile(name: name, bio: bio, photoUrl: photoUrl);
    showMessage(context, 'Profile saved.');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final scheme = Theme.of(context).colorScheme;
    final busy = auth.busy || profile.busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErrorNotice(profile.errorMessage, onRetry: profile.retry),
        ErrorNotice(auth.errorMessage),
        ErrorNotice(accountProvider.errorMessage, onRetry: accountProvider.retry),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? const [Color(0xFF603341), Color(0xFF332429)]
                  : const [AppTheme.softPink, AppTheme.softCream, AppTheme.offWhite],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 620;
              final avatar = ValueListenableBuilder<TextEditingValue>(
                valueListenable: _photoUrl,
                builder: (context, value, child) => ProfileAvatar(
                  photoUrl: value.text,
                  size: 92,
                  backgroundColor: scheme.surface,
                ),
              );
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _name,
                    builder: (context, value, child) => Text(
                      value.text.trim().isEmpty ? 'Your account' : value.text.trim(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user.isDemo ? 'Local demo workspace' : widget.user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<AccountProvider>(
                    builder: (context, account, child) => Chip(
                      avatar: Icon(
                        account.isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : account.isCook
                                ? Icons.restaurant_menu_rounded
                                : account.isVisitor
                                    ? Icons.person_outline_rounded
                                    : account.loading
                                        ? Icons.hourglass_top_rounded
                                        : Icons.warning_amber_rounded,
                        size: 16,
                      ),
                      label: Text(account.roleLabel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Edit your information below. Save changes only activates when something has changed.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [avatar, const SizedBox(height: 18), details],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [avatar, const SizedBox(width: 24), Expanded(child: details)],
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        SurfaceCard(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeading(
                  'Personal information',
                  subtitle: 'Your profile photo, name, email, and kitchen bio.',
                ),
                TextFormField(
                  controller: _name,
                  validator: InputValidators.name,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  validator: widget.user.isDemo ? null : InputValidators.email,
                  enabled: !widget.user.isDemo,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    helperText: widget.user.isDemo
                        ? 'Demo workspaces do not have a real sign-in email.'
                        : 'Changing this sends a verification link to the new address.',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _photoUrl,
                  validator: _photoValidator,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Profile photo URL',
                    hintText: 'https://example.com/my-photo.jpg',
                    prefixIcon: Icon(Icons.photo_camera_outlined),
                    helperText: 'Leave this empty to use the default human icon.',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bio,
                  maxLength: 240,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'About you',
                    hintText: 'Tell Liza’s Kitchen a little about your cooking style...',
                    prefixIcon: Icon(Icons.auto_awesome_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dirty ? 'Unsaved changes' : 'Everything is up to date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _dirty ? scheme.primary : scheme.onSurfaceVariant,
                              fontWeight: _dirty ? FontWeight.w700 : FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: !_dirty || busy ? null : _save,
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Save changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        const SectionHeading(
          'Your kitchen at a glance',
          subtitle: 'A snapshot of the things you are collecting and planning.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Stat(
              icon: Icons.favorite_rounded,
              label: 'Saved recipes',
              value: context.watch<FavoritesProvider>().ids.length,
            ),
            _Stat(
              icon: Icons.calendar_month_rounded,
              label: 'Planned meals',
              value: context.watch<MealPlanProvider>().entries.length,
            ),
            _Stat(
              icon: Icons.shopping_bag_rounded,
              label: 'Grocery items',
              value: context.watch<GroceryProvider>().items.length,
            ),
          ],
        ),
        const SizedBox(height: 28),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: const _TileIcon(icon: Icons.tune_rounded),
                title: const Text('Settings & appearance'),
                subtitle: const Text('Theme and local preferences'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const Divider(),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: const _TileIcon(icon: Icons.favorite_outline_rounded),
                title: const Text("About Liza's Kitchen"),
                subtitle: const Text('A softer way to discover, plan, and cook.'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: "Liza's Kitchen",
                  applicationVersion: '1.0.0',
                  applicationIcon: const BrandMark(),
                  children: const [
                    Text(
                      'Built with Flutter, Provider, and optional Firebase. Recipe images are original illustrations. '
                      'Sample recipes are demonstration content, not personalized dietary advice.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (widget.user.isDemo)
          const InfoBanner(
            'Demo data stays on this device. Real, cross-device accounts require Firebase mode.',
            icon: Icons.favorite_outline_rounded,
          ),
      ],
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 172,
        child: SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 15),
              Text('$value', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 5),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
