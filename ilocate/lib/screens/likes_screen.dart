import 'package:flutter/material.dart';

import '../data/likes.dart';
import '../data/place.dart';
import '../widgets/place_tile.dart';

class LikesScreen extends StatelessWidget {
  final List<Place> places;

  const LikesScreen({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Likes')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: likes,
        builder: (context, liked, _) {
          final saved = places.where((p) => liked.contains(p.id)).toList();
          if (saved.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No likes yet. Tap the heart on a place to save it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: saved.length,
            itemBuilder: (context, i) => PlaceTile(place: saved[i]),
          );
        },
      ),
    );
  }
}
