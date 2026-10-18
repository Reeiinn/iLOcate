import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';
import 'error_view.dart';

/// Current weather at [point], loaded from Open-Meteo with a FutureBuilder.
/// Shows a spinner while loading, the weather on success, and an error with
/// a retry button on failure.
class WeatherCard extends StatefulWidget {
  final LatLng point;

  const WeatherCard({super.key, required this.point});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Future<Weather> _future;

  @override
  void initState() {
    super.initState();
    // Created once here, not in build(), so rebuilds don't refetch.
    _future = _fetch();
  }

  Future<Weather> _fetch() =>
      context.read<WeatherService>().fetchCurrent(widget.point);

  void _retry() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Weather>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Row(children: [
                SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Checking the weather...'),
              ]);
            }
            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error!,
                onRetry: _retry,
                compact: true,
              );
            }
            return _WeatherDetails(weather: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _WeatherDetails extends StatelessWidget {
  final Weather weather;

  const _WeatherDetails({required this.weather});

  IconData get _icon {
    if (weather.code >= 95) return Icons.thunderstorm_outlined;
    if (weather.isRainy) return Icons.umbrella_outlined;
    if (weather.code == 0) return Icons.wb_sunny_outlined;
    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(_icon, size: 40, color: theme.colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}°C · ${weather.description}',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Feels like ${weather.feelsLike.round()}°C · '
                'Humidity ${weather.humidity}% · '
                'Wind ${weather.windSpeed.round()} km/h',
                style: theme.textTheme.bodySmall,
              ),
              if (weather.isRainy)
                Text('Bring an umbrella for the walk.',
                    style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
