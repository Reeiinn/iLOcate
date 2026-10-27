import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/likes_provider.dart';
import 'providers/location_provider.dart';
import 'providers/places_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/trips_provider.dart';
import 'services/api_client.dart';
import 'services/asset_data_service.dart';
import 'services/directions_service.dart';
import 'services/local_store.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore(await SharedPreferences.getInstance());
  final api = ApiClient(http.Client());

  runApp(
    MultiProvider(
      providers: [
        // Services: plain objects, read with context.read<T>().
        Provider.value(value: WeatherService(api)),
        Provider.value(value: DirectionsService(api)),
        // Shared app state: ChangeNotifiers that screens watch.
        ChangeNotifierProvider(
          create: (_) => PlacesProvider(AssetDataService())..load(),
        ),
        ChangeNotifierProvider(create: (_) => LikesProvider(store)),
        ChangeNotifierProvider(create: (_) => TripsProvider(store)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(store)),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(LocationService()),
        ),
      ],
      child: const ILocateApp(),
    ),
  );
}
