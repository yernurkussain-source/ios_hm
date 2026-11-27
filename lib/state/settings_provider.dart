import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const darkModeKey = 'app_theme_dark_mode';
  static const nameKey = 'user_display_name';
  static const defaultName = 'Guest User';

  final SharedPreferences _prefs;
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
