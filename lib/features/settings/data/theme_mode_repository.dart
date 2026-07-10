import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeRepository {
  ThemeModeRepository({SharedPreferencesAsync? preferences}) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _themeModeKey = 'theme_mode';

  final SharedPreferencesAsync _preferences;

  Future<ThemeMode> loadThemeMode() async {
    final value = await _preferences.getString(_themeModeKey);
    return _themeModeFromValue(value);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) => _preferences.setString(_themeModeKey, themeMode.name);

  ThemeMode _themeModeFromValue(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
