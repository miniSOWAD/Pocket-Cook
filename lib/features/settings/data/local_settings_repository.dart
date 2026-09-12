import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/storage/key_value_store.dart';
import 'settings_repository.dart';
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this.storage);
  final KeyValueStore storage;
  @override
  ThemeMode readTheme() {
    final current = storage.read('lizas_kitchen.theme');
    final name = current ?? storage.read('savor.theme');
    if (current == null && name != null) unawaited(storage.write('lizas_kitchen.theme', name));
    return ThemeMode.values.firstWhere((mode) => mode.name == name, orElse: () => ThemeMode.system);
  }
  @override
  Future<void> saveTheme(ThemeMode mode) => storage.write('lizas_kitchen.theme', mode.name);
}
