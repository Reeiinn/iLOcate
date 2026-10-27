import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/likes_provider.dart';
import '../providers/places_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/trips_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearLikes(BuildContext context) async {
    final likes = context.read<LikesProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all likes?'),
        content: Text('This removes ${likes.count} liked places.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) await likes.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final likeCount = context.select<LikesProvider, int>((l) => l.count);
    final tripCount = context.select<TripsProvider, int>((t) => t.trips.length);
    final data = context.read<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Theme', style: theme.textTheme.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Clear likes'),
            subtitle: Text('$likeCount liked places'),
            enabled: likeCount > 0,
            onTap: () => _clearLikes(context),
          ),
          ListTile(
            leading: const Icon(Icons.luggage_outlined),
            title: const Text('Saved trips'),
            subtitle: Text('$tripCount trips on this phone'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About iLOcate'),
            subtitle: Text(
              '${data.places.length} places · ${data.routes.length} jeepney '
              'routes in Iloilo City',
            ),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'iLOcate',
              applicationVersion: '1.0.0',
              applicationIcon: Image.asset('assets/images/logo.png', width: 48),
              children: const [
                Text(
                  'Map tiles © OpenStreetMap contributors. Weather by '
                  'Open-Meteo. Directions by OSRM.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
