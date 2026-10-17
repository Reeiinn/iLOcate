import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/likes_provider.dart';
import 'providers/places_provider.dart';
import 'services/asset_data_service.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore(await SharedPreferences.getInstance());

  runApp(
    MultiProvider(
      providers: [
        // Shared app state: ChangeNotifiers that screens watch.
        ChangeNotifierProvider(
          create: (_) => PlacesProvider(AssetDataService())..load(),
        ),
        ChangeNotifierProvider(create: (_) => LikesProvider(store)),
      ],
      child: const ILocateApp(),
    ),
  );
}
