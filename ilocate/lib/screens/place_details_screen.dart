import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../data/likes.dart';
import '../data/place.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name, overflow: TextOverflow.ellipsis),
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: likes,
            builder: (context, liked, _) {
              final isLiked = liked.contains(place.id);
              return IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                color: isLiked ? Colors.red : null,
                onPressed: () => toggleLike(place.id),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Image.asset(place.image, height: 220, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Chip(
                  label: Text(place.type),
                  side: BorderSide(color: colorForType(place.type)),
                ),
                const SizedBox(height: 8),
                Text(
                  '${place.location.latitude.toStringAsFixed(5)}, '
                  '${place.location.longitude.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: place.location,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.reeiinn.ilocate',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: place.location,
                    width: 36,
                    height: 36,
                    child: Icon(Icons.location_on, color: colorForType(place.type), size: 36),
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              // Directions (OSRM) is not built yet in this prototype.
              onPressed: null,
              icon: const Icon(Icons.directions),
              label: const Text('Directions (coming soon)'),
            ),
          ),
        ],
      ),
    );
  }
}
