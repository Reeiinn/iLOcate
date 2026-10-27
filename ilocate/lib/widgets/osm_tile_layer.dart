import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

/// Center of Iloilo City, the default camera position.
const iloiloCenter = LatLng(10.7202, 122.5621);

/// OpenStreetMap tiles, shared by every map in the app so the URL and the
/// user agent (required by the OSM tile policy) live in one place.
class OsmTileLayer extends StatelessWidget {
  const OsmTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.reeiinn.ilocate',
    );
  }
}

/// A map pin colored by place type.
Marker placeMarker(
  LatLng point,
  String type, {
  double size = 32,
  VoidCallback? onTap,
}) {
  return Marker(
    point: point,
    width: size,
    height: size,
    alignment: Alignment.topCenter,
    child: GestureDetector(
      onTap: onTap,
      child: Icon(Icons.location_on, color: colorForType(type), size: size),
    ),
  );
}
