import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/models/puj_route.dart';
import 'package:ilocate/services/commute_planner.dart';
import 'package:latlong2/latlong.dart';

PujRoute _route(String number, List<LatLng> points) => PujRoute(
      number: number,
      name: number,
      color: const Color(0xFF000000),
      goingTo: points,
      goingBack: const [],
    );

void main() {
  const a = LatLng(10.700, 122.560);
  const b = LatLng(10.720, 122.560);

  test('finds routes that pass near both ends, closest first', () {
    final near = _route('R1', [a, b]);
    final slightlyOff = _route('R2', [
      const LatLng(10.7020, 122.560),
      const LatLng(10.7180, 122.560),
    ]);
    final farAway = _route('R3', [
      const LatLng(10.800, 122.700),
      const LatLng(10.810, 122.700),
    ]);

    final result = jeepneysServing(a, b, [farAway, slightlyOff, near]);
    expect(result.map((r) => r.number), ['R1', 'R2']);
  });

  test('ignores a route that only reaches one end', () {
    final halfway = _route('R4', [a, const LatLng(10.705, 122.560)]);
    expect(jeepneysServing(a, b, [halfway]), isEmpty);
  });
}
