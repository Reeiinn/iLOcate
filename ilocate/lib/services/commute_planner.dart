import 'package:latlong2/latlong.dart';

import '../models/puj_route.dart';

const _distance = Distance();

/// Jeepney routes whose path passes within [walkMeters] of both [from] and
/// [to], so the rider can walk to the route, ride, and walk to the place.
/// Sorted by total walking distance, shortest first.
List<PujRoute> jeepneysServing(
  LatLng from,
  LatLng to,
  List<PujRoute> routes, {
  double walkMeters = 500,
}) {
  final matches = <(PujRoute, double)>[];
  for (final route in routes) {
    final walkFrom = _closestDistance(from, route.allPoints);
    if (walkFrom > walkMeters) continue;
    final walkTo = _closestDistance(to, route.allPoints);
    if (walkTo > walkMeters) continue;
    matches.add((route, walkFrom + walkTo));
  }
  matches.sort((a, b) => a.$2.compareTo(b.$2));
  return [for (final m in matches) m.$1];
}

double _closestDistance(LatLng point, Iterable<LatLng> path) {
  var best = double.infinity;
  for (final p in path) {
    final d = _distance(point, p);
    if (d < best) best = d;
  }
  return best;
}
