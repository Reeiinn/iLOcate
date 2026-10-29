import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilocate/providers/places_provider.dart';
import 'package:ilocate/providers/trips_provider.dart';
import 'package:ilocate/routes/app_router.dart';
import 'package:ilocate/screens/trip_form_screen.dart';
import 'package:ilocate/services/asset_data_service.dart';
import 'package:ilocate/services/local_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('validateTripTitle', () {
    test('rejects empty and short names', () {
      expect(validateTripTitle(''), isNotNull);
      expect(validateTripTitle('  a '), isNotNull);
    });

    test('accepts a normal name', () {
      expect(validateTripTitle('Food crawl'), isNull);
    });
  });

  group('validateTripDate', () {
    final now = DateTime(2026, 10, 29, 15, 30);

    test('rejects a missing or past date', () {
      expect(validateTripDate(null, now: now), isNotNull);
      expect(validateTripDate(DateTime(2026, 10, 28), now: now), isNotNull);
    });

    test('accepts today and future dates', () {
      expect(validateTripDate(DateTime(2026, 10, 29), now: now), isNull);
      expect(validateTripDate(DateTime(2026, 11, 5), now: now), isNull);
    });
  });

  testWidgets('saving an empty form shows every validation error',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    final trips = TripsProvider(store);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlacesProvider(AssetDataService()),
        ),
        ChangeNotifierProvider.value(value: trips),
      ],
      child: const MaterialApp(
        home: TripFormScreen(args: TripFormArgs()),
      ),
    ));

    await tester.ensureVisible(find.text('Save trip'));
    await tester.tap(find.text('Save trip'));
    await tester.pump();

    expect(find.text('Give the trip a name'), findsOneWidget);
    expect(find.text('Pick a date'), findsOneWidget);
    expect(find.text('Add at least one place'), findsOneWidget);
    expect(trips.trips, isEmpty);
  });
}
