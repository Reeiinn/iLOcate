import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../models/puj_route.dart';
import '../providers/location_provider.dart';
import '../providers/places_provider.dart';
import '../routes/app_router.dart';
import '../widgets/osm_tile_layer.dart';
import '../widgets/place_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Which routes are drawn and whether pins are visible only matter to this
  // screen, so they stay in local State rather than a Provider.
  final Set<String> _shownRoutes = {};
  bool _showPlaces = true;
  final _mapController = MapController();

  Future<void> _goToMyLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    final location = context.read<LocationProvider>();
    final point = await location.locate();
    if (!mounted) return;
    if (point == null) {
      messenger.showSnackBar(SnackBar(content: Text(location.error!)));
      return;
    }
    _mapController.move(point, 16);
  }

  List<Polyline> _polylines(List<PujRoute> routes) {
    final lines = <Polyline>[];
    for (final route in routes) {
      if (!_shownRoutes.contains(route.number)) continue;
      for (final points in [route.goingTo, route.goingBack]) {
        if (points.length < 2) continue;
        lines.add(Polyline(points: points, color: route.color, strokeWidth: 4));
      }
    }
    return lines;
  }

  void _openRoutePicker(List<PujRoute> routes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void update(VoidCallback change) {
            setState(change);
            setSheetState(() {});
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            builder: (context, controller) => Column(
              children: [
                ListTile(
                  title: const Text(
                    'Jeepney routes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: TextButton(
                    onPressed: _shownRoutes.isEmpty
                        ? null
                        : () => update(_shownRoutes.clear),
                    child: const Text('Clear'),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      for (final route in routes)
                        CheckboxListTile(
                          value: _shownRoutes.contains(route.number),
                          onChanged: (_) => update(() {
                            if (!_shownRoutes.remove(route.number)) {
                              _shownRoutes.add(route.number);
                            }
                          }),
                          secondary: CircleAvatar(
                            radius: 8,
                            backgroundColor: route.color,
                          ),
                          title: Text(route.number),
                          subtitle: Text(route.name),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlacePreview(Place place) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: PlaceImage(place: place, width: 64, height: 64),
          title: Text(place.name),
          subtitle: Text(place.type),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(sheetContext);
            Navigator.pushNamed(
              context,
              AppRoutes.placeDetails,
              arguments: place,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<PlacesProvider>();
    final location = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('iLOcate'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showPlaces ? 'Hide places' : 'Show places',
            icon: Icon(_showPlaces ? Icons.location_on : Icons.location_off),
            onPressed: () => setState(() => _showPlaces = !_showPlaces),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: iloiloCenter,
          initialZoom: 13.5,
        ),
        children: [
          const OsmTileLayer(),
          PolylineLayer(polylines: _polylines(data.routes)),
          if (_showPlaces)
            MarkerLayer(
              markers: [
                for (final place in data.places)
                  placeMarker(
                    place.location,
                    place.type,
                    size: 28,
                    onTap: () => _showPlacePreview(place),
                  ),
              ],
            ),
          if (location.position != null)
            MarkerLayer(markers: [
              Marker(
                point: location.position!,
                width: 22,
                height: 22,
                child: const _MyLocationDot(),
              ),
            ]),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'my-location',
            tooltip: 'My location',
            onPressed: location.isLocating ? null : _goToMyLocation,
            child: location.isLocating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'routes',
            onPressed: () => _openRoutePicker(data.routes),
            icon: const Icon(Icons.directions_bus),
            label: Text(
              _shownRoutes.isEmpty
                  ? 'Routes'
                  : 'Routes (${_shownRoutes.length})',
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue dot for the user's GPS position.
class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
    );
  }
}
