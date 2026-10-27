import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../models/puj_route.dart';
import '../services/asset_data_service.dart';

enum LoadStatus { loading, ready, error }

/// Holds the landmark list and jeepney routes. Every tab and the detail,
/// trip and directions screens read places from here instead of having the
/// list passed down through constructors.
class PlacesProvider extends ChangeNotifier {
  final AssetDataService _data;

  PlacesProvider(this._data);

  LoadStatus _status = LoadStatus.loading;
  String? _error;
  List<Place> _places = const [];
  List<PujRoute> _routes = const [];
  Map<String, Place> _byId = const {};

  LoadStatus get status => _status;
  String? get error => _error;
  List<Place> get places => _places;
  List<PujRoute> get routes => _routes;

  Place? placeById(String id) => _byId[id];

  /// Places matching a search query and an optional type filter.
  List<Place> search(String query, {String? type}) {
    final q = query.trim().toLowerCase();
    return _places.where((p) {
      if (type != null && p.type != type) return false;
      return q.isEmpty || p.name.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _data.loadPlaces(),
        _data.loadRoutes(),
      ]);
      _places = results[0] as List<Place>;
      _routes = results[1] as List<PujRoute>;
      _byId = {for (final p in _places) p.id: p};
      _status = LoadStatus.ready;
    } catch (e) {
      _error = 'Could not load the map data ($e).';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }
}
