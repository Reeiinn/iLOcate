import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/likes_provider.dart';
import '../providers/places_provider.dart';
import '../widgets/error_view.dart';
import 'likes_screen.dart';
import 'map_screen.dart';
import 'places_screen.dart';
import 'trips_screen.dart';

/// The home route: four tabs behind a bottom navigation bar. Shows a loading
/// screen until the bundled place data is ready.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlacesProvider>();

    switch (places.status) {
      case LoadStatus.loading:
        return const _LoadingScreen();
      case LoadStatus.error:
        return Scaffold(
          body: ErrorView(error: places.error!, onRetry: places.load),
        );
      case LoadStatus.ready:
        break;
    }

    final likeCount = context.select<LikesProvider, int>((l) => l.count);
    return Scaffold(
      // IndexedStack keeps each tab alive, so the map keeps its position
      // and the search box keeps its text when switching tabs.
      body: IndexedStack(
        index: _tab,
        children: const [
          MapScreen(),
          PlacesScreen(),
          TripsScreen(),
          LikesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Places',
          ),
          const NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: likeCount > 0,
              label: Text('$likeCount'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Likes',
          ),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
