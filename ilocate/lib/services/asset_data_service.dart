import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/place.dart';
import '../models/puj_route.dart';

/// Reads the bundled landmark and jeepney route data. These ship with the app
/// so the map still has pins and routes when the phone is offline.
class AssetDataService {
  final AssetBundle _bundle;

  AssetDataService([AssetBundle? bundle]) : _bundle = bundle ?? rootBundle;

  Future<List<Place>> loadPlaces() async {
    final raw = await _bundle.loadString('assets/data/landmarks.json');
    final list = jsonDecode(raw) as List;
    return list.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PujRoute>> loadRoutes() async {
    final raw = await _bundle.loadString('assets/data/routes.json');
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => PujRoute.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  }
}
