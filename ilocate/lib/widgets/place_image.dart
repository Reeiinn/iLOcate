import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/app_theme.dart';

/// A place's photo with rounded corners. Falls back to a colored icon if the
/// asset is missing, so one bad file never breaks a list.
class PlaceImage extends StatelessWidget {
  final Place place;
  final double? width;
  final double height;
  final double radius;

  const PlaceImage({
    super.key,
    required this.place,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        place.image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: width,
          height: height,
          color: colorForType(place.type).withValues(alpha: 0.15),
          child: Icon(Icons.image_not_supported_outlined,
              color: colorForType(place.type)),
        ),
      ),
    );
  }
}
