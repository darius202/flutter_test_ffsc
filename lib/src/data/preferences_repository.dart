import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/shopping_item.dart';

/// Persists user data (favorites, shopping list, settings) on the device.
class PreferencesRepository {
  PreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const favoritesKey = 'favorites';
  static const shoppingKey = 'shopping_list';
  static const themeKey = 'theme_mode';
  static const localeKey = 'locale';

  Set<String> readFavorites() =>
      (_prefs.getStringList(favoritesKey) ?? const []).toSet();

  Future<void> writeFavorites(Set<String> ids) =>
      _prefs.setStringList(favoritesKey, ids.toList()..sort());

  List<ShoppingItem> readShoppingList() {
    final raw = _prefs.getString(shoppingKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List<dynamic>)
          ShoppingItem.fromJson(item as Map<String, dynamic>),
      ];
    } on Object {
      // Corrupted data must never crash the app: start from an empty list.
      return const [];
    }
  }

  Future<void> writeShoppingList(List<ShoppingItem> items) => _prefs.setString(
        shoppingKey,
        jsonEncode([for (final item in items) item.toJson()]),
      );

  ThemeMode readThemeMode() {
    final name = _prefs.getString(themeKey);
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(themeKey, mode.name);

  /// `null` means "follow the device language".
  Locale? readLocale() {
    final code = _prefs.getString(localeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> writeLocale(Locale? locale) => locale == null
      ? _prefs.remove(localeKey)
      : _prefs.setString(localeKey, locale.languageCode);
}
