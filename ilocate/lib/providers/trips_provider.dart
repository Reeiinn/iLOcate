import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import '../services/local_store.dart';

/// Create, read, update and delete for trip plans. The list is kept sorted
/// by date and written to the device after every change.
class TripsProvider extends ChangeNotifier {
  final LocalStore _store;
  final List<Trip> _trips;

  TripsProvider(this._store) : _trips = _store.loadTrips() {
    _sort();
  }

  List<Trip> get trips => List.unmodifiable(_trips);

  Trip? byId(String id) {
    for (final t in _trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Creates a trip and returns it (the id is generated here).
  Future<Trip> add({
    required String title,
    required DateTime date,
    String notes = '',
    List<String> placeIds = const [],
  }) async {
    final trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      date: date,
      notes: notes,
      placeIds: placeIds,
    );
    _trips.add(trip);
    await _changed();
    return trip;
  }

  Future<void> update(Trip trip) async {
    final i = _trips.indexWhere((t) => t.id == trip.id);
    if (i == -1) return;
    _trips[i] = trip;
    await _changed();
  }

  Future<void> delete(String id) async {
    _trips.removeWhere((t) => t.id == id);
    await _changed();
  }

  /// Puts a deleted trip back (used by the "Undo" snackbar).
  Future<void> restore(Trip trip) async {
    if (byId(trip.id) != null) return;
    _trips.add(trip);
    await _changed();
  }

  /// Adds a place to an existing trip. Returns false if it was already there.
  Future<bool> addPlace(String tripId, String placeId) async {
    final trip = byId(tripId);
    if (trip == null || trip.placeIds.contains(placeId)) return false;
    await update(trip.copyWith(placeIds: [...trip.placeIds, placeId]));
    return true;
  }

  Future<void> _changed() async {
    _sort();
    notifyListeners();
    await _store.saveTrips(_trips);
  }

  void _sort() => _trips.sort((a, b) => a.date.compareTo(b.date));
}
