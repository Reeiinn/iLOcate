import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/likes_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/place_tile.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlacesProvider>();
    final liked = context
        .watch<LikesProvider>()
        .ids
        .map(places.placeById)
        .whereType<Place>()
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Likes')),
      body: liked.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No likes yet',
              message: 'Tap the heart on a place to save it here.',
            )
          : ListView.builder(
              itemCount: liked.length,
              itemBuilder: (context, i) => PlaceTile(place: liked[i]),
            ),
    );
  }
}
