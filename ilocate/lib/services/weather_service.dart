import 'package:latlong2/latlong.dart';

import '../models/weather.dart';
import 'api_client.dart';

/// Fetches current weather from Open-Meteo (https://open-meteo.com).
/// Free and keyless, so nothing secret ships in the APK.
class WeatherService {
  static const _host = 'api.open-meteo.com';

  final ApiClient _api;

  WeatherService(this._api);

  Future<Weather> fetchCurrent(LatLng point) async {
    final uri = Uri.https(_host, '/v1/forecast', {
      'latitude': point.latitude.toStringAsFixed(4),
      'longitude': point.longitude.toStringAsFixed(4),
      'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,'
          'weather_code,wind_speed_10m',
      'timezone': 'Asia/Manila',
    });
    final json = await _api.getJson(uri);
    try {
      return Weather.fromJson(json);
    } on Object {
      // Missing or mistyped fields: treat like any other bad response.
      throw const ApiException('Weather data was incomplete.');
    }
  }
}
