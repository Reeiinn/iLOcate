import 'package:latlong2/latlong.dart';

/// Decodes a Google-style encoded polyline. iLOcate's jeepney routes and the
/// OSRM `polyline6` geometry both use 6 decimal places, hence the default.
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
