import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'English';
  String _languageCode = 'en';
  Locale _locale = const Locale('en');

  String get currentLanguage => _currentLanguage;
  String get languageCode => _languageCode;
  Locale get locale => _locale;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Arabic', 'code': 'ar'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'Spanish', 'code': 'es'},
  ];

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(_languageCode);
    _currentLanguage = languages.firstWhere(
      (l) => l['code'] == _languageCode,
      orElse: () => languages[0],
    )['name']!;
    notifyListeners();
  }

  Future<void> setLanguage(String name, String code) async {
    _currentLanguage = name;
    _languageCode = code;
    _locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    notifyListeners();
  }
}
