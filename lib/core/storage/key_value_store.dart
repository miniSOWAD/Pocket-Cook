import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class PreferencesKeyValueStore implements KeyValueStore {
  PreferencesKeyValueStore(this.preferences);
  final SharedPreferences preferences;
  @override
  String? read(String key) => preferences.getString(key);
  @override
  Future<void> write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw StateError('Local storage write failed');
    }
  }
  @override
  Future<void> remove(String key) async {
    if (!await preferences.remove(key)) throw StateError('Local storage remove failed');
  }
}

class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};
  @override
  String? read(String key) => values[key];
  @override
  Future<void> write(String key, String value) async { values[key] = value; }
  @override
  Future<void> remove(String key) async { values.remove(key); }
}
