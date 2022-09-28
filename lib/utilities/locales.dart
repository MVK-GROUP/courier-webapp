import 'package:flutter/material.dart';

class LocaleObject {
  final String code;
  final String title;
  final Locale locale;

  const LocaleObject({
    required this.code,
    required this.title,
    required this.locale,
  });
}

class SupportedLocales {
  static final _locales = [
    const LocaleObject(code: "uk", title: "Українська", locale: Locale('uk')),
    const LocaleObject(code: "en", title: "English", locale: Locale('en')),
  ];

  static LocaleObject get defaultLocale {
    return const LocaleObject(
        code: "uj", title: "Українська", locale: Locale('uk'));
  }

  static LocaleObject getLocaleByCode(String code) {
    return _locales.firstWhere((locale) => locale.code == code,
        orElse: () => defaultLocale);
  }

  static List<LocaleObject> get lockaleObjects {
    return _locales;
  }

  static List<Locale> get locales {
    return _locales.map((e) => e.locale).toList();
  }

  static List<String> get languages {
    return _locales.map((e) => e.title).toList();
  }
}
