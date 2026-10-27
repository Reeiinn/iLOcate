import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ilocate/services/api_client.dart';
import 'package:ilocate/services/directions_service.dart';
import 'package:ilocate/services/weather_service.dart';
import 'package:latlong2/latlong.dart';

const _point = LatLng(10.72, 122.56);

ApiClient _apiReturning(int status, Object body) => ApiClient(
      MockClient((_) async => http.Response(jsonEncode(body), status)),
    );

void main() {
  group('WeatherService', () {
    test('returns weather on 200', () async {
      final service = WeatherService(_apiReturning(200, {
        'current': {
          'time': '2026-10-27T14:00',
          'temperature_2m': 29.0,
          'apparent_temperature': 33.0,
          'relative_humidity_2m': 75,
          'weather_code': 0,
          'wind_speed_10m': 8.0,
        },
      }));
      final weather = await service.fetchCurrent(_point);
      expect(weather.description, 'Clear sky');
    });

    test('maps a server error to ApiException', () {
      final service = WeatherService(_apiReturning(500, {}));
      expect(
        service.fetchCurrent(_point),
        throwsA(isA<ApiException>()
            .having((e) => e.isOffline, 'isOffline', isFalse)),
      );
    });

    test('maps a network failure to an offline ApiException', () {
      final api = ApiClient(MockClient((_) async {
        throw http.ClientException('Failed host lookup');
      }));
      expect(
        WeatherService(api).fetchCurrent(_point),
        throwsA(isA<ApiException>()
            .having((e) => e.isOffline, 'isOffline', isTrue)),
      );
    });
  });

  group('DirectionsService', () {
    test('sends lng,lat pairs and parses the route', () async {
      late Uri requested;
      final api = ApiClient(MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'code': 'Ok',
            'routes': [
              {
                'distance': 900,
                'duration': 120,
                'geometry': '_malS__nwhFo}@o}@',
              },
            ],
          }),
          200,
        );
      }));
      final result = await DirectionsService(api)
          .fetchRoute(_point, const LatLng(10.70, 122.57));
      expect(requested.path, contains('122.56,10.72;122.57,10.7'));
      expect(result.distanceLabel, '900 m');
    });

    test('turns NoRoute into a friendly ApiException', () {
      final service = DirectionsService(
        _apiReturning(200, {'code': 'NoRoute', 'routes': []}),
      );
      expect(service.fetchRoute(_point, _point), throwsA(isA<ApiException>()));
    });
  });
}
