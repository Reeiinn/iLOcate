/// Current weather at a place, parsed from the Open-Meteo forecast API.
///
/// Sample response (trimmed):
/// ```json
/// {
///   "latitude": 10.72, "longitude": 122.56,
///   "current": {
///     "time": "2026-10-27T14:00", "temperature_2m": 30.4,
///     "apparent_temperature": 35.1, "relative_humidity_2m": 70,
///     "weather_code": 2, "wind_speed_10m": 11.2
///   }
/// }
/// ```
class Weather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int code;
  final DateTime time;

  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.code,
    required this.time,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const FormatException('Missing "current" block');
    }
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      code: (current['weather_code'] as num).toInt(),
      time: DateTime.parse(current['time'] as String),
    );
  }

  /// Short label for a WMO weather code.
  String get description {
    if (code == 0) return 'Clear sky';
    if (code <= 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }

  /// A rough "should I bring an umbrella" hint for commuters.
  bool get isRainy => (code >= 51 && code <= 67) || code >= 80;
}
