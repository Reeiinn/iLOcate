import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

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
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: LatLng(json['lat'], json['lng']),
      image: json['image'],
    );
  }

  bool get isFood => type == 'Food' || type == 'Cafe';
}

const placeTypes = ['Food', 'Cafe', 'Church', 'Museum', 'Heritage', 'Mall', 'Beach', 'Urban'];

Color colorForType(String type) {
  switch (type) {
    case 'Food':
      return const Color(0xFFE0592A);
    case 'Cafe':
      return const Color(0xFF8D5B3A);
    case 'Church':
      return const Color(0xFF5B4FA8);
    case 'Museum':
    case 'Heritage':
      return const Color(0xFFB08A1E);
    case 'Mall':
      return const Color(0xFF2B7BBF);
    case 'Beach':
      return const Color(0xFF1AA6A6);
    default:
      return const Color(0xFF5B6A6C);
  }
}

Future<List<Place>> loadPlaces() async {
  final raw = await rootBundle.loadString('assets/data/landmarks.json');
  final list = jsonDecode(raw) as List;
  return list.map((e) => Place.fromJson(e)).toList();
}
