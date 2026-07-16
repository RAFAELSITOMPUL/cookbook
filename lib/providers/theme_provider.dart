import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSizeFactor = 1.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSizeFactor => _fontSizeFactor;

  ThemeProvider() {
    _loadFromPrefs();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  void setFontSizeFactor(double factor) {
    _fontSizeFactor = factor;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _fontSizeFactor = prefs.getDouble('fontSizeFactor') ?? 1.0;
    notifyListeners();
  }

  _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setDouble('fontSizeFactor', _fontSizeFactor);
  }
}
