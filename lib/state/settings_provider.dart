import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LAB 11: dark mode + username, stored as key-value pairs on disk.
class SettingsProvider extends ChangeNotifier {
  static const darkModeKey = 'app_theme_dark_mode';
  static const nameKey = 'user_display_name';
  static const defaultName = 'Guest User';

  final SharedPreferences _prefs;

  // Read synchronously from the instance loaded before runApp(), so the very
  // first frame already has the right theme (no white flash).
  SettingsProvider(this._prefs)
    : darkMode = _prefs.getBool(darkModeKey) ?? false,
      displayName = _prefs.getString(nameKey) ?? defaultName;

  bool darkMode;
  String displayName;

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await _prefs.setBool(darkModeKey, value);
  }

  Future<void> saveName(String name) async {
    final trimmed = name.trim();
    displayName = trimmed.isEmpty ? defaultName : trimmed;
    notifyListeners();
    await _prefs.setString(nameKey, displayName);
  }
}
