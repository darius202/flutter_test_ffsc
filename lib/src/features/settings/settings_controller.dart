import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';

@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// `null` follows the device language.
  final Locale? locale;

  @override
  bool operator ==(Object other) =>
      other is AppSettings && other.themeMode == themeMode && other.locale == locale;

  @override
  int get hashCode => Object.hash(themeMode, locale);
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.watch(preferencesRepositoryProvider);
    return AppSettings(themeMode: repo.readThemeMode(), locale: repo.readLocale());
  }

  Future<void> setThemeMode(ThemeMode mode) {
    state = AppSettings(themeMode: mode, locale: state.locale);
    return ref.read(preferencesRepositoryProvider).writeThemeMode(mode);
  }

  Future<void> setLocale(Locale? locale) {
    state = AppSettings(themeMode: state.themeMode, locale: locale);
    return ref.read(preferencesRepositoryProvider).writeLocale(locale);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
