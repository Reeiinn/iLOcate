import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/providers/likes_provider.dart';
import 'package:ilocate/providers/trips_provider.dart';
import 'package:ilocate/services/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<LocalStore> _freshStore() async {
  SharedPreferences.setMockInitialValues({});
  return LocalStore(await SharedPreferences.getInstance());
}

void main() {
  group('TripsProvider', () {
    test('create, read, update and delete', () async {
      final trips = TripsProvider(await _freshStore());

      final trip = await trips.add(
        title: 'Heritage walk',
        date: DateTime(2026, 11, 2),
        placeIds: const ['molo-church'],
      );
      expect(trips.trips, hasLength(1));
      expect(trips.byId(trip.id)?.title, 'Heritage walk');

      await trips.update(trip.copyWith(title: 'Molo heritage walk'));
      expect(trips.byId(trip.id)?.title, 'Molo heritage walk');

      await trips.delete(trip.id);
      expect(trips.trips, isEmpty);
    });

    test('keeps trips sorted by date and saved across restarts', () async {
      final store = await _freshStore();
      final trips = TripsProvider(store);
      await trips.add(title: 'Later', date: DateTime(2026, 12, 1));
      await trips.add(title: 'Sooner', date: DateTime(2026, 11, 1));
      expect(trips.trips.map((t) => t.title), ['Sooner', 'Later']);

      final reopened = TripsProvider(store);
      expect(reopened.trips.map((t) => t.title), ['Sooner', 'Later']);
    });

    test('addPlace ignores duplicates', () async {
      final trips = TripsProvider(await _freshStore());
      final trip = await trips.add(title: 'Cafes', date: DateTime(2026));
      expect(await trips.addPlace(trip.id, 'a'), isTrue);
      expect(await trips.addPlace(trip.id, 'a'), isFalse);
      expect(trips.byId(trip.id)?.placeIds, ['a']);
    });
  });

  group('LikesProvider', () {
    test('toggles and persists likes', () async {
      final store = await _freshStore();
      final likes = LikesProvider(store);
      await likes.toggle('molo-church');
      expect(likes.isLiked('molo-church'), isTrue);

      expect(LikesProvider(store).isLiked('molo-church'), isTrue);

      await likes.toggle('molo-church');
      expect(likes.isLiked('molo-church'), isFalse);
    });
  });
}
