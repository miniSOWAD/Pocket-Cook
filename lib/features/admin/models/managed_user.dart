import '../../accounts/models/app_role.dart';

class ManagedUser {
  const ManagedUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final AppRole role;
  final AccountStatus status;
  final int createdAt;

  bool get disabled => status == AccountStatus.blocked;

  factory ManagedUser.fromJson(Map<String, dynamic> json) => ManagedUser(
        uid: json['uid'] as String? ?? '',
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? 'Home cook',
        photoUrl: json['photoUrl'] as String? ?? '',
        role: AppRoleX.parse(json['role']),
        status: AccountStatusX.parse(json['status']),
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      );
}
