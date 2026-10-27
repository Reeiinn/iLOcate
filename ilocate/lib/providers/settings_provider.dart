import 'package:flutter/material.dart';

import '../services/local_store.dart';

/// App-wide preferences. MaterialApp watches this to switch themes.
class SettingsProvider extends ChangeNotifier {
  final LocalStore _store;
  ThemeMode _themeMode;

  SettingsProvider(this._store) : _themeMode = _store.loadThemeMode();

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store.saveThemeMode(mode);
  }
}
