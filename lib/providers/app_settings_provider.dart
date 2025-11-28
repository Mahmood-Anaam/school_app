import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  bool _isDark = false;
  Locale _locale = const Locale('ar');
  bool _initialized = false;

  bool get isDark => _isDark;
  Locale get locale => _locale;
  bool get initialized => _initialized;

  AppSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    final langCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(langCode);
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }
}
