import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/core/storage/key_value_store.dart';
import 'package:pocket_cook/features/settings/data/local_settings_repository.dart';
import 'package:pocket_cook/features/settings/presentation/providers/settings_provider.dart';
void main() {
  test('theme preference survives repository recreation', () async {
    final storage = MemoryKeyValueStore(); final repository = LocalSettingsRepository(storage);
    final settings = SettingsProvider(repository);
    expect(settings.themeMode, ThemeMode.system);
    expect(await settings.setTheme(ThemeMode.dark), isTrue);
    expect(LocalSettingsRepository(storage).readTheme(), ThemeMode.dark);
    settings.dispose();
  });
}
