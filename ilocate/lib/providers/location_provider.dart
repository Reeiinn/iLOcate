import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

/// The user's last known GPS position. Shared by the map (blue dot and
/// "my location" button) and the directions screen ("start from my location").
class LocationProvider extends ChangeNotifier {
  final LocationService _service;

  LocationProvider(this._service);

  LatLng? _position;
  bool _locating = false;
  String? _error;

  LatLng? get position => _position;
  bool get isLocating => _locating;
  String? get error => _error;

  /// Reads the position once. Returns it, or null if it failed (see [error]).
  Future<LatLng?> locate() async {
    if (_locating) return _position;
    _locating = true;
    _error = null;
    notifyListeners();
    try {
      _position = await _service.currentPosition();
    } on LocationException catch (e) {
      _error = e.message;
    } on TimeoutException {
      _error = 'Could not get a GPS fix. Try again near a window or outside.';
    } catch (e) {
      _error = 'Could not read your location.';
    }
    _locating = false;
    notifyListeners();
    return _error == null ? _position : null;
  }
}
