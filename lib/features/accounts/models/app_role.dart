enum AppRole { admin, cook, visitor }

enum AccountStatus { active, blocked }

extension AppRoleX on AppRole {
  String get value => name;
  String get label => switch (this) {
        AppRole.admin => 'Admin',
        AppRole.cook => 'Cook',
        AppRole.visitor => 'Visitor',
      };

  bool get canManageRecipes => this == AppRole.admin || this == AppRole.cook;

  static AppRole parse(Object? value) => switch (value) {
        'admin' => AppRole.admin,
        'cook' => AppRole.cook,
        _ => AppRole.visitor,
      };
}

extension AccountStatusX on AccountStatus {
  String get value => name;
  String get label => this == AccountStatus.blocked ? 'Blocked' : 'Active';

  static AccountStatus parse(Object? value) =>
      value == 'blocked' ? AccountStatus.blocked : AccountStatus.active;
}
