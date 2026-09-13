import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common.dart';
import '../../../accounts/models/app_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../models/managed_user.dart';
import '../providers/admin_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AdminProvider>().loadUsers());
  }

  Future<void> _createUser() async {
    final result = await showDialog<_NewUserData>(
      context: context,
      builder: (_) => const _CreateUserDialog(),
    );
    if (result == null || !mounted) return;
    final admin = context.read<AdminProvider>();
    final ok = await admin.createUser(
      email: result.email,
      password: result.password,
      displayName: result.displayName,
      role: result.role,
    );
    if (mounted) showMessage(context, ok ? 'User created.' : admin.errorMessage ?? 'Could not create user.');
  }

  Future<void> _delete(ManagedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('This permanently deletes ${user.displayName} from Firebase Authentication and their app data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final admin = context.read<AdminProvider>();
    final ok = await admin.deleteUser(user.uid);
    if (mounted) showMessage(context, ok ? 'User deleted.' : admin.errorMessage ?? 'Could not delete user.');
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final currentUid = context.watch<AuthProvider>().user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage users')),
      body: SafeArea(
        child: FeaturePage(
          title: 'People in the kitchen.',
          subtitle: 'Create accounts, change roles, block access, or remove users. Passwords are never visible to admins.',
          eyebrow: 'Admin only',
          trailing: FilledButton.icon(
            onPressed: admin.busy ? null : _createUser,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add user'),
          ),
          child: Column(
            children: [
              ErrorNotice(admin.errorMessage, onRetry: admin.loadUsers),
              if (admin.busy && admin.users.isEmpty)
                const LoadingView()
              else if (admin.users.isEmpty)
                const EmptyStateView(title: 'No users found', message: 'Refresh or create a new user.')
              else
                for (final user in admin.users)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final details = Row(
                          children: [
                            ProfileAvatar(photoUrl: user.photoUrl, size: 46),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
                                  Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 7),
                                  Wrap(spacing: 7, runSpacing: 7, children: [
                                    Chip(label: Text(user.role.label)),
                                    Chip(label: Text(user.status.label)),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        );
                        final controls = Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            DropdownButton<AppRole>(
                              value: user.role,
                              onChanged: admin.busy || user.uid == currentUid
                                  ? null
                                  : (role) async {
                                      if (role == null) return;
                                      final ok = await context.read<AdminProvider>().setRole(user.uid, role);
                                      if (context.mounted && !ok) showMessage(context, context.read<AdminProvider>().errorMessage ?? 'Could not change role.');
                                    },
                              items: AppRole.values
                                  .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                                  .toList(),
                            ),
                            OutlinedButton.icon(
                              onPressed: admin.busy || user.uid == currentUid
                                  ? null
                                  : () async {
                                      final ok = await context.read<AdminProvider>().setBlocked(user.uid, !user.disabled);
                                      if (context.mounted) showMessage(context, ok ? (user.disabled ? 'User unblocked.' : 'User blocked.') : context.read<AdminProvider>().errorMessage ?? 'Could not update user.');
                                    },
                              icon: Icon(user.disabled ? Icons.lock_open_rounded : Icons.block_rounded),
                              label: Text(user.disabled ? 'Unblock' : 'Block'),
                            ),
                            IconButton(
                              tooltip: 'Delete user',
                              onPressed: admin.busy || user.uid == currentUid ? null : () => _delete(user),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        );
                        if (constraints.maxWidth < 720) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [details, const SizedBox(height: 12), controls]);
                        }
                        return Row(children: [Expanded(child: details), const SizedBox(width: 18), controls]);
                      }),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewUserData {
  const _NewUserData(this.email, this.password, this.displayName, this.role);
  final String email;
  final String password;
  final String displayName;
  final AppRole role;
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();
  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  AppRole role = AppRole.visitor;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add a user'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: name, validator: InputValidators.name, decoration: const InputDecoration(labelText: 'Display name')),
              const SizedBox(height: 12),
              TextFormField(controller: email, validator: InputValidators.email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                validator: (value) => (value ?? '').length < 8 ? 'Use at least 8 characters.' : null,
                decoration: const InputDecoration(labelText: 'Temporary password'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AppRole>(
                value: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: AppRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                onChanged: (value) => setState(() => role = value ?? AppRole.visitor),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              Navigator.pop(context, _NewUserData(email.text.trim(), password.text, name.text.trim(), role));
            },
            child: const Text('Create user'),
          ),
        ],
      );
}
