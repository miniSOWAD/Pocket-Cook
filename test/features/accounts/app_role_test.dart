import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/features/accounts/models/app_account.dart';
import 'package:recipe_app/features/accounts/models/app_role.dart';

void main() {
  test('database roles parse to the expected permissions', () {
    expect(AppRoleX.parse('admin'), AppRole.admin);
    expect(AppRoleX.parse('cook'), AppRole.cook);
    expect(AppRoleX.parse('visitor'), AppRole.visitor);
    expect(AppRoleX.parse('unknown'), AppRole.visitor);
    expect(AppRole.admin.canManageRecipes, isTrue);
    expect(AppRole.cook.canManageRecipes, isTrue);
    expect(AppRole.visitor.canManageRecipes, isFalse);
  });

  test('blocked accounts are not allowed to manage recipes', () {
    const account = AppAccount(
      uid: 'cook',
      displayName: 'Cook',
      photoUrl: '',
      role: AppRole.cook,
      status: AccountStatus.blocked,
      createdAt: 1,
      updatedAt: 1,
    );
    expect(account.canManageRecipes, isFalse);
  });
}
