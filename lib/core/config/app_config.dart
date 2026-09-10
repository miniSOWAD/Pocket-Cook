import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const useFirebase = bool.fromEnvironment('USE_FIREBASE');
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');
  static const emulatorProjectId = 'demo-recipe-app';
  static String get emulatorHost {
    const configured = String.fromEnvironment('EMULATOR_HOST');
    if (configured.isNotEmpty) return configured;
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
  }
}
