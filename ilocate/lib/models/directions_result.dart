import 'package:latlong2/latlong.dart';

import '../utils/polyline.dart';

/// A route between two points, parsed from an OSRM `/route` response.
///
/// Sample response (trimmed):
/// ```json
/// {
///   "code": "Ok",
///   "routes": [
///     { "distance": 4210.3, "duration": 612.8, "geometry": "a~l~Fjk~uO..." }
///   ]
/// }
/// ```
class DirectionsResult {
  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> points;

  const DirectionsResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.points,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    if (json['code'] != 'Ok') {
      throw FormatException('OSRM returned ${json['code']}');
    }
    final routes = json['routes'] as List;
    if (routes.isEmpty) throw const FormatException('No route found');
    final best = routes.first as Map<String, dynamic>;
    return DirectionsResult(
      distanceMeters: (best['distance'] as num).toDouble(),
      durationSeconds: (best['duration'] as num).toDouble(),
      points: decodePolyline(best['geometry'] as String),
    );
  }

  String get distanceLabel => distanceMeters >= 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
      : '${distanceMeters.round()} m';

  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }
}
