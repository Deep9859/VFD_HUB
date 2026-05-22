import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  // Supported languages with names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
  };

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh'),
  ];

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final currentIndex = supportedLocales.indexOf(_locale);
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await setLocale(supportedLocales[nextIndex]);
  }

  String getLanguageName(String code) {
    return supportedLanguages[code] ?? code;
  }

  String get currentLanguageName => getLanguageName(_locale.languageCode);
}
