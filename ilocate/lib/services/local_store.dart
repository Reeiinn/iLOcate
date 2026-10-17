import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app saves on the device, behind one class so providers do
/// not need to know about SharedPreferences keys or JSON encoding.
class LocalStore {
  static const _likesKey = 'liked_place_ids';

  final SharedPreferences _prefs;

  LocalStore(this._prefs);

  Set<String> loadLikes() => (_prefs.getStringList(_likesKey) ?? []).toSet();

  Future<void> saveLikes(Set<String> ids) =>
      _prefs.setStringList(_likesKey, ids.toList());
}
