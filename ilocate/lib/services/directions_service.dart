import 'package:latlong2/latlong.dart';

import '../models/directions_result.dart';
import 'api_client.dart';

/// Road directions from the public OSRM demo server
/// (https://project-osrm.org). OSRM expects "lng,lat" pairs.
class DirectionsService {
  static const _host = 'router.project-osrm.org';

  final ApiClient _api;

  DirectionsService(this._api);

  Future<DirectionsResult> fetchRoute(LatLng from, LatLng to) async {
    final coords = '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}';
    final uri = Uri.https(_host, '/route/v1/driving/$coords', {
      'overview': 'full',
      'geometries': 'polyline6',
    });
    final json = await _api.getJson(uri);
    try {
      return DirectionsResult.fromJson(json);
    } on FormatException catch (e) {
      throw ApiException('No road route found (${e.message}).');
    } on Object {
      throw const ApiException('Directions data was incomplete.');
    }
  }
}
