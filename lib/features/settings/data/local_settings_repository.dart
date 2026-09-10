import 'package:flutter/material.dart';
import '../../../core/storage/key_value_store.dart';
import 'settings_repository.dart';
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this.storage);
  final KeyValueStore storage;
  @override
  ThemeMode readTheme() {
    final name = storage.read('savor.theme');
    return ThemeMode.values.firstWhere((mode) => mode.name == name, orElse: () => ThemeMode.system);
  }
  @override
  Future<void> saveTheme(ThemeMode mode) => storage.write('savor.theme', mode.name);
}
