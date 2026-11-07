
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider = ChangeNotifierProvider<AppSettings>(
  (ref) => AppSettings(),
);

class AppSettings extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';

  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.dark;

  bool isLoaded = false;

  AppSettings() {
    _loadSettings();
  }

  String get languageCode => _languageCode;

  ThemeMode get themeMode => _themeMode;

  Locale get locale => Locale(_languageCode);

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ne': 'नेपाली (Nepali)',
    'hi': 'हिन्दी (Hindi)',
    'bn': 'বাংলা (Bengali)',
    'zh': '中文 (Chinese)',
    'es': 'Español (Spanish)',
    'fr': 'Français (French)',
    'ar': 'العربية (Arabic)',
  };

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedLanguage = preferences.getString(_languageKey);
      final savedTheme = preferences.getString(_themeKey);

      if (savedLanguage != null &&
          supportedLanguages.containsKey(savedLanguage)) {
        _languageCode = savedLanguage;
      }

      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    } catch (error) {
      debugPrint('Could not load app settings: $error');
    }

    isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      return;
    }

    _languageCode = languageCode;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_languageKey, languageCode);
    } catch (error) {
      debugPrint('Could not save language: $error');
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    _themeMode = theme;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        _themeKey,
        theme == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (error) {
      debugPrint('Could not save theme: $error');
    }
  }

  Future<void> toggleTheme() async {
    await setTheme(
      _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }
}
