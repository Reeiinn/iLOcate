import 'package:flutter/material.dart';

import '../data/likes.dart';
import '../data/place.dart';
import '../screens/place_details_screen.dart';

class PlaceTile extends StatelessWidget {
  final Place place;

  const PlaceTile({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(place.image, width: 56, height: 56, fit: BoxFit.cover),
      ),
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(place.type, style: TextStyle(color: colorForType(place.type))),
      trailing: ValueListenableBuilder<Set<String>>(
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailsScreen(place: place)),
      ),
    );
  }
}
