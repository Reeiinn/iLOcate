import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// A jeepney (PUJ) route. Points come from encoded polylines with
/// 6 decimal places of precision, same as the web version.
class PujRoute {
  final String number;
  final String name;
  final Color color;
  final List<LatLng> goingTo;
  final List<LatLng> goingBack;

  PujRoute({
    required this.number,
    required this.name,
    required this.color,
    required this.goingTo,
    required this.goingBack,
  });

  factory PujRoute.fromJson(Map<String, dynamic> json) {
    final hex = (json['color'] as String).replaceFirst('#', '');
    return PujRoute(
      number: json['number'],
      name: json['name'],
      color: Color(int.parse('FF$hex', radix: 16)),
      goingTo: decodePolyline(json['goingTo'] ?? ''),
      goingBack: decodePolyline(json['goingBack'] ?? ''),
    );
  }
}

List<LatLng> decodePolyline(String encoded, {int precision = 1000000}) {
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;

  int nextValue() {
    var result = 0;
    var shift = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);
    // -(n) - 1 instead of ~n: on web, ~ gives an unsigned 32-bit result
    return (result & 1) != 0 ? -(result >> 1) - 1 : (result >> 1);
  }

  while (index < encoded.length) {
    lat += nextValue();
    if (index >= encoded.length) break;
    lng += nextValue();
    points.add(LatLng(lat / precision, lng / precision));
  }
  return points;
}

Future<List<PujRoute>> loadRoutes() async {
  final raw = await rootBundle.loadString('assets/data/routes.json');
  final list = jsonDecode(raw) as List;
  final routes = list.map((e) => PujRoute.fromJson(e)).toList();
  // R1, R2 ... R55 instead of R1, R10, R11 ...
  int num(PujRoute r) => int.tryParse(r.number.replaceAll(RegExp(r'\D'), '')) ?? 0;
  routes.sort((a, b) => num(a).compareTo(num(b)));
  return routes;
}
