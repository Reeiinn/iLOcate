import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/models/place.dart';
import 'package:ilocate/models/trip.dart';

void main() {
  group('Place', () {
    test('parses landmark json', () {
      final place = Place.fromJson({
        'id': 'molo-church',
        'name': 'Molo Church',
        'type': 'Church',
        'lat': 10.6969,
        'lng': 122.5446,
        'image': 'assets/images/places/molo-church.jpg',
      });
      expect(place.name, 'Molo Church');
      expect(place.location.latitude, 10.6969);
      expect(place.isFood, isFalse);
    });
  });

  group('Trip', () {
    test('survives a json round trip', () {
      final trip = Trip(
        id: '1',
        title: 'Food crawl',
        date: DateTime(2026, 10, 31),
        notes: 'Bring cash',
        placeIds: const ['a', 'b'],
      );
      final copy = Trip.fromJson(trip.toJson());
      expect(copy.title, 'Food crawl');
      expect(copy.date, DateTime(2026, 10, 31));
      expect(copy.placeIds, ['a', 'b']);
    });

    test('copyWith keeps the id', () {
      final trip = Trip(id: 'x', title: 'A', date: DateTime(2026));
      final edited = trip.copyWith(title: 'B');
      expect(edited.id, 'x');
      expect(edited.title, 'B');
    });
  });
}
