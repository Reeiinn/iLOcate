import 'package:flutter/material.dart';

import '../models/place.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import 'like_button.dart';
import 'place_image.dart';

/// One row in a list of places: photo, name, type and a like button.
/// Tapping it opens the place's detail screen. Pass [trailing] to replace
/// the like button (the trip screen uses a remove button instead).
class PlaceTile extends StatelessWidget {
  final Place place;
  final Widget? trailing;

  const PlaceTile({super.key, required this.place, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PlaceImage(place: place, width: 56, height: 56),
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        place.type,
        style: TextStyle(color: colorForType(place.type)),
      ),
      trailing: trailing ?? LikeButton(placeId: place.id),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.placeDetails,
        arguments: place,
      ),
    );
  }
}
