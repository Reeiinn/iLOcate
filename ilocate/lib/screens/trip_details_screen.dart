import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../providers/places_provider.dart';
import '../providers/trips_provider.dart';
import '../routes/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/place_tile.dart';

/// One trip. Receives the trip id (not the Trip object) so it always shows
/// the latest version from TripsProvider after an edit.
class TripDetailsScreen extends StatelessWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  Future<void> _confirmDelete(BuildContext context, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text('"$title" will be removed from this phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<TripsProvider>().delete(tripId);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.select<TripsProvider, Trip?>((t) => t.byId(tripId));
    if (trip == null) {
      // Deleted while this screen was open.
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.luggage_outlined,
          title: 'Trip not found',
          message: 'This trip was deleted.',
        ),
      );
    }

    final theme = Theme.of(context);
    final places = context.read<PlacesProvider>();
    final stops =
        trip.placeIds.map(places.placeById).whereType<Place>().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.tripForm,
              arguments: TripFormArgs(trip: trip),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, trip.title),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.event, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(DateFormat('EEEE, MMMM d, yyyy').format(trip.date),
                      style: theme.textTheme.titleMedium),
                ]),
                if (trip.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(trip.notes, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),
                Text('Stops (${stops.length})',
                    style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          if (stops.isEmpty)
            const EmptyState(
              icon: Icons.add_location_alt_outlined,
              title: 'No stops yet',
              message: 'Edit the trip to add places.',
            )
          else
            for (final (i, place) in stops.indexed)
              PlaceTile(
                place: place,
                trailing: i == 0
                    ? null
                    : IconButton(
                        tooltip: 'Directions from previous stop',
                        icon: const Icon(Icons.directions),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.directions,
                          arguments: DirectionsArgs(
                            to: place,
                            from: stops[i - 1],
                          ),
                        ),
                      ),
              ),
        ],
      ),
    );
  }
}
