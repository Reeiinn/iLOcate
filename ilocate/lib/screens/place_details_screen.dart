import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/trips_provider.dart';
import '../routes/app_router.dart';
import '../widgets/like_button.dart';
import '../widgets/osm_tile_layer.dart';
import '../widgets/place_image.dart';
import '../widgets/type_chip.dart';
import '../widgets/weather_card.dart';

/// Detail screen for one place. Receives the [Place] as the route argument.
class PlaceDetailsScreen extends StatelessWidget {
  static const _newTrip = '__new_trip__';

  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  Future<void> _addToTrip(BuildContext context) async {
    final trips = context.read<TripsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // A trip id, _newTrip, or null if the sheet was dismissed.
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New trip with this place'),
              onTap: () => Navigator.pop(sheetContext, _newTrip),
            ),
            for (final trip in trips.trips)
              ListTile(
                leading: const Icon(Icons.luggage_outlined),
                title: Text(trip.title),
                subtitle: Text(DateFormat.yMMMd().format(trip.date)),
                enabled: !trip.placeIds.contains(place.id),
                trailing: trip.placeIds.contains(place.id)
                    ? const Text('Added')
                    : null,
                onTap: () => Navigator.pop(sheetContext, trip.id),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;
    if (choice == _newTrip) {
      Navigator.pushNamed(
        context,
        AppRoutes.tripForm,
        arguments: TripFormArgs(initialPlaceId: place.id),
      );
    } else {
      await trips.addPlace(choice, place.id);
      messenger.showSnackBar(
        SnackBar(content: Text('Added to ${trips.byId(choice)?.title}')),
      );
    }
  }

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
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToTrip(context),
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Add to trip'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
