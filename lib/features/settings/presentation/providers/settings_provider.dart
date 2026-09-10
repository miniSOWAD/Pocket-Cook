import 'package:flutter/material.dart';
import '../../../../core/state/async_notifier.dart';
import '../../data/settings_repository.dart';
class SettingsProvider extends AsyncNotifier {
  SettingsProvider(this.repository) : themeMode = repository.readTheme();
  final SettingsRepository repository;
  ThemeMode themeMode;
  Future<bool> setTheme(ThemeMode value) => run(() async {
    await repository.saveTheme(value);
    themeMode = value;
  });
}
