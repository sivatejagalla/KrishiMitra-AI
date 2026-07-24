import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Box _box;

  ThemeNotifier(this._box) : super(_loadTheme(_box));

  static ThemeMode _loadTheme(Box box) {
    final theme = box.get('theme_mode', defaultValue: 'system');
    if (theme == 'light') return ThemeMode.light;
    if (theme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    final modeStr = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system');
    _box.put('theme_mode', modeStr);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(Hive.box('settings'));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Box _box;

  LocaleNotifier(this._box) : super(_loadLocale(_box));

  static Locale _loadLocale(Box box) {
    final lang = box.get('locale', defaultValue: 'en');
    return Locale(lang);
  }

  void setLocale(Locale locale) {
    state = locale;
    _box.put('locale', locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(Hive.box('settings'));
});
