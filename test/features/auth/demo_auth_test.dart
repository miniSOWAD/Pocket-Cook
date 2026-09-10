import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/core/storage/key_value_store.dart';
import 'package:recipe_app/core/errors/app_exception.dart';
import 'package:recipe_app/features/auth/data/demo_auth_repository.dart';
void main() {
  test('demo access persists without storing passwords', () async {
    final storage = MemoryKeyValueStore(); final auth = DemoAuthRepository(storage);
    await auth.enterDemo(); expect(auth.currentUser!.isDemo, isTrue);
    final restored = DemoAuthRepository(storage); expect(restored.currentUser!.uid, 'demo-user');
    expect(storage.values.keys.any((key) => key.contains('password')), isFalse);
    await auth.signOut(); expect(auth.currentUser, isNull);
    await auth.dispose(); await restored.dispose();
  });
  test('demo mode does not pretend to authenticate passwords', () async {
    final auth = DemoAuthRepository(MemoryKeyValueStore());
    await expectLater(auth.signIn('user@example.test', 'password'), throwsA(isA<AppException>()));
    expect(auth.currentUser, isNull); await auth.dispose();
  });
}
