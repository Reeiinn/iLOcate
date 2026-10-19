import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/models/directions_result.dart';
import 'package:ilocate/models/weather.dart';

void main() {
  group('Weather', () {
    test('parses the Open-Meteo current block', () {
      final weather = Weather.fromJson({
        'current': {
          'time': '2026-10-27T14:00',
          'temperature_2m': 30.4,
          'apparent_temperature': 35.1,
          'relative_humidity_2m': 70,
          'weather_code': 61,
          'wind_speed_10m': 11.2,
        },
      });
      expect(weather.temperature, 30.4);
      expect(weather.description, 'Rain');
      expect(weather.isRainy, isTrue);
    });

    test('throws when the current block is missing', () {
      expect(() => Weather.fromJson({}), throwsFormatException);
    });
  });

  group('DirectionsResult', () {
    test('parses an OSRM route', () {
      final result = DirectionsResult.fromJson({
        'code': 'Ok',
        'routes': [
          {
            'distance': 4210.3,
            'duration': 612.8,
            'geometry': '_malS__nwhFo}@o}@',
          },
        ],
      });
      expect(result.distanceLabel, '4.2 km');
      expect(result.durationLabel, '11 min');
      expect(result.points.length, 2);
    });

    test('rejects a NoRoute response', () {
      expect(
        () => DirectionsResult.fromJson({'code': 'NoRoute', 'routes': []}),
        throwsFormatException,
      );
    });
  });
}
