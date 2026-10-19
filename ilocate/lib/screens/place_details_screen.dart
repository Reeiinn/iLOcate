import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/place.dart';
import '../routes/app_router.dart';
import '../widgets/like_button.dart';
import '../widgets/osm_tile_layer.dart';
import '../widgets/place_image.dart';
import '../widgets/type_chip.dart';
import '../widgets/weather_card.dart';

/// Detail screen for one place. Receives the [Place] as the route argument.
class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name, overflow: TextOverflow.ellipsis),
        actions: [LikeButton(placeId: place.id)],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PlaceImage(place: place, height: 220, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                TypeChip(type: place.type),
                const SizedBox(height: 4),
                Text(
                  '${place.location.latitude.toStringAsFixed(5)}, '
                  '${place.location.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          WeatherCard(point: place.location),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: place.location,
                initialZoom: 16,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                const OsmTileLayer(),
                MarkerLayer(markers: [
                  placeMarker(place.location, place.type, size: 36),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.directions,
                arguments: place,
              ),
              icon: const Icon(Icons.directions),
              label: const Text('Directions'),
            ),
          ),
        ],
      ),
    );
  }
}
