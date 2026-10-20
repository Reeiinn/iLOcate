import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../models/trip.dart';
import '../providers/places_provider.dart';
import 'place_image.dart';

/// Summary card for a trip: date, title, place count and a strip of photos.
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final places = context.read<PlacesProvider>();
    final photos =
        trip.placeIds.map(places.placeById).whereType<Place>().take(4).toList();

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEE, MMM d, yyyy').format(trip.date),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(trip.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                trip.placeIds.length == 1
                    ? '1 place'
                    : '${trip.placeIds.length} places',
                style: theme.textTheme.bodySmall,
              ),
              if (photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  for (final p in photos)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PlaceImage(place: p, width: 56, height: 56),
                    ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
