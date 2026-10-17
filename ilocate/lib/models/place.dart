import 'package:latlong2/latlong.dart';

/// A landmark, restaurant, cafe or other spot shown on the map.
/// Loaded from assets/data/landmarks.json.
class Place {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final String image;

  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.image,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      image: json['image'] as String,
    );
  }

  bool get isFood => type == 'Food' || type == 'Cafe';
}

const placeTypes = [
  'Food',
  'Cafe',
  'Church',
  'Museum',
  'Heritage',
  'Mall',
  'Beach',
  'Urban',
];
