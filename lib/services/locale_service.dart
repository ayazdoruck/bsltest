import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

// Kullanicinin secili dilini kalici tutar. Uygulama genelinde anlik dil
// degisimi icin global bir ValueNotifier kullanilir (Provider/Riverpod gibi
// bir state-yonetim paketi eklemeden, mevcut proje deseniyle tutarli).
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

class LocaleService {
  static const _localeKey = 'locale_code';

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      appLocaleNotifier.value = AppLocalizations.supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('en'),
      );
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    appLocaleNotifier.value = locale;
  }
}
