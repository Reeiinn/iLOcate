import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/data/puj_route.dart';

void main() {
  test('decodes a polyline6 string', () {
    // Two points: (10.70000, 122.56000) and (10.70100, 122.56100)
    const encoded = '_malS__nwhFo}@o}@';
    final points = decodePolyline(encoded);

    expect(points.length, 2);
    expect(points[0].latitude, closeTo(10.7, 1e-6));
    expect(points[0].longitude, closeTo(122.56, 1e-6));
    expect(points[1].latitude, closeTo(10.701, 1e-6));
    expect(points[1].longitude, closeTo(122.561, 1e-6));
  });
}
