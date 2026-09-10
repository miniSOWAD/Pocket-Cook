import 'package:flutter/material.dart';
abstract interface class SettingsRepository {
  ThemeMode readTheme();
  Future<void> saveTheme(ThemeMode mode);
}
