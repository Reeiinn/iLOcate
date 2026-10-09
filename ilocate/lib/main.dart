import 'package:flutter/material.dart';

import 'data/place.dart';
import 'data/puj_route.dart';
import 'screens/likes_screen.dart';
import 'screens/map_screen.dart';
import 'screens/places_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final places = await loadPlaces();
  final routes = await loadRoutes();
  runApp(ILocateApp(places: places, routes: routes));
}

class ILocateApp extends StatelessWidget {
  final List<Place> places;
  final List<PujRoute> routes;

  const ILocateApp({super.key, required this.places, required this.routes});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iLOcate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B8080)),
        useMaterial3: true,
      ),
      home: HomeShell(places: places, routes: routes),
    );
  }
}

class HomeShell extends StatefulWidget {
  final List<Place> places;
  final List<PujRoute> routes;

  const HomeShell({super.key, required this.places, required this.routes});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          MapScreen(places: widget.places, routes: widget.routes),
          PlacesScreen(places: widget.places),
          LikesScreen(places: widget.places),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Places'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Likes'),
        ],
      ),
    );
  }
}
