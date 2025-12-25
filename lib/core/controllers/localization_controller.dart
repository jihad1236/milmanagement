import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });
}

class LocalizationController extends GetxController {
  static const _storageKey = 'selected_language_code';

  final Rx<Locale> _locale = const Locale('en', 'US').obs;
  final RxString _languageName = 'English'.obs;

  Rx<Locale> get locale => _locale;
  RxString get languageName => _languageName;
  String get selectedLanguageName => _languageName.value;
  LanguageOption get currentLanguage => languages.firstWhere(
    (lang) => lang.code == _locale.value.languageCode,
    orElse: () => languages.first,
  );

  final List<LanguageOption> languages = const [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: Locale('en', 'US'),
    ),
    LanguageOption(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      locale: Locale('es', 'ES'),
    ),
    LanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      locale: Locale('fr', 'FR'),
    ),
    LanguageOption(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      locale: Locale('de', 'DE'),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> changeLanguage(LanguageOption option) async {
    if (_locale.value == option.locale) return;
    _locale.value = option.locale;
    _languageName.value = option.name;
    Get.updateLocale(option.locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, option.code);
  }

  Future<void> changeLanguageByName(String name) async {
    final option = languages.firstWhere(
      (lang) => lang.name == name,
      orElse: () => languages.first,
    );
    await changeLanguage(option);
  }

  bool isSelected(LanguageOption option) =>
      _locale.value.languageCode == option.code;

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code == null) return;
    final option = languages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => languages.first,
    );
    _locale.value = option.locale;
    _languageName.value = option.name;
    Get.updateLocale(option.locale);
  }
}
