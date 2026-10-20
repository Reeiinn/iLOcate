import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip.dart';

/// Everything the app saves on the device, behind one class so providers do
/// not need to know about SharedPreferences keys or JSON encoding.
class LocalStore {
  static const _likesKey = 'liked_place_ids';
  static const _tripsKey = 'trips';
  static const _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  LocalStore(this._prefs);

  Set<String> loadLikes() => (_prefs.getStringList(_likesKey) ?? []).toSet();

  Future<void> saveLikes(Set<String> ids) =>
      _prefs.setStringList(_likesKey, ids.toList());

  List<Trip> loadTrips() {
    final raw = _prefs.getString(_tripsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
    } on Object {
      // Corrupt data should not crash the app on launch; start fresh instead.
      return [];
    }
  }

  Future<void> saveTrips(List<Trip> trips) => _prefs.setString(
        _tripsKey,
        jsonEncode(trips.map((t) => t.toJson()).toList()),
      );

  ThemeMode loadThemeMode() {
    final name = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);
}
