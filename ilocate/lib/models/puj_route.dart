import 'dart:ui';

import 'package:latlong2/latlong.dart';

import '../utils/polyline.dart';

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
      number: json['number'] as String,
      name: json['name'] as String,
      color: Color(int.parse('FF$hex', radix: 16)),
      goingTo: decodePolyline(json['goingTo'] as String? ?? ''),
      goingBack: decodePolyline(json['goingBack'] as String? ?? ''),
    );
  }

  /// Numeric part of the route number, used for sorting (R1, R2 ... R55).
  int get sortKey => int.tryParse(number.replaceAll(RegExp(r'\D'), '')) ?? 0;

  Iterable<LatLng> get allPoints => goingTo.followedBy(goingBack);
}
