import 'package:flutter/foundation.dart';

import '../services/local_store.dart';

/// Liked place ids, saved on the device so likes survive an app restart.
class LikesProvider extends ChangeNotifier {
  final LocalStore _store;
  final Set<String> _ids;

  LikesProvider(this._store) : _ids = _store.loadLikes();

  Set<String> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;

  bool isLiked(String placeId) => _ids.contains(placeId);

  Future<void> toggle(String placeId) async {
    if (!_ids.remove(placeId)) _ids.add(placeId);
    notifyListeners();
    await _store.saveLikes(_ids);
  }

  Future<void> clear() async {
    _ids.clear();
    notifyListeners();
    await _store.saveLikes(_ids);
  }
}
