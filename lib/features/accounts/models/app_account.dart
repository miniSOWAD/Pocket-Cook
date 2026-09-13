import 'app_role.dart';

class AppAccount {
  const AppAccount({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String displayName;
  final String photoUrl;
  final AppRole role;
  final AccountStatus status;
  final int createdAt;
  final int updatedAt;

  bool get isActive => status == AccountStatus.active;
  bool get isAdmin => role == AppRole.admin;
  bool get isCook => role == AppRole.cook;
  bool get isVisitor => role == AppRole.visitor;
  bool get canManageRecipes => isActive && role.canManageRecipes;

  factory AppAccount.fromJson(String uid, Map<String, dynamic> json) => AppAccount(
        uid: uid,
        displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
            ? (json['displayName'] as String).trim()
            : 'Home cook',
        photoUrl: json['photoUrl'] as String? ?? '',
        role: AppRoleX.parse(json['role']),
        status: AccountStatusX.parse(json['status']),
        createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role.value,
        'status': status.value,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
